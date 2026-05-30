const http = require("http");
const express = require("express");
const { Server } = require("socket.io");
const escpos = require("escpos");
const cors = require("cors");
const fs = require("fs");
const os = require("os");
const path = require("path");
const QRCode = require("qrcode");

escpos.Network = require("escpos-network");

const app = express();
const server = http.createServer(app);

const allowedOrigins = [
  "http://localhost:3000",
  "http://127.0.0.1:3000"
];

const corsOptions = {
  origin(origin, callback) {
    // Allow same-machine tools that don't send Origin and local frontend origins.
    if (!origin || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }

    return callback(new Error("Not allowed by CORS"));
  },
  methods: ["GET", "POST", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  optionsSuccessStatus: 204
};

app.use(cors(corsOptions));
app.options("*", cors(corsOptions));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));




const io = new Server(server, {
  cors: {
    origin: "*"
  }
});

app.use(cors());
app.use(express.json({ limit: "5mb" }));
app.use(express.urlencoded({ extended: true, limit: "5mb" }));

app.get("/health", (req, res) => {
  res.json({ success: true, status: "ok" });
});

const formatLeftRight = (left, right, lineWidth = 32) => {
  const leftText = String(left || "");
  const rightText = String(right || "");
  const spaces = lineWidth - leftText.length - rightText.length;

  if (spaces > 0) {
    return `${leftText}${" ".repeat(spaces)}${rightText}`;
  }

  return `${leftText} ${rightText}`;
};

const padRight = (value, width) => String(value || "").slice(0, width).padEnd(width, " ");
const padLeft = (value, width) => String(value || "").slice(-width).padStart(width, " ");

const toCurrency = (value) => {
  const amount = Number(value || 0);
  if (Number.isNaN(amount)) {
    return "฿0.00";
  }
  return `฿${amount.toFixed(2)}`;
};

const toAmount = (value) => {
  const amount = Number(value || 0);
  if (Number.isNaN(amount)) {
    return "0.00";
  }
  return amount.toFixed(2);
};

const toBool = (value) => {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value === 1;
  if (typeof value === "string") {
    const normalized = value.trim().toLowerCase();
    return normalized === "true" || normalized === "1" || normalized === "yes";
  }
  return false;
};

const wrapText = (text, width) => {
  const input = String(text || "").trim();
  if (!input) return [""];

  const words = input.split(/\s+/);
  const lines = [];
  let currentLine = "";

  words.forEach((word) => {
    if (word.length > width) {
      if (currentLine) {
        lines.push(currentLine);
        currentLine = "";
      }
      for (let i = 0; i < word.length; i += width) {
        lines.push(word.slice(i, i + width));
      }
      return;
    }

    const trial = currentLine ? `${currentLine} ${word}` : word;
    if (trial.length <= width) {
      currentLine = trial;
    } else {
      lines.push(currentLine);
      currentLine = word;
    }
  });

  if (currentLine) {
    lines.push(currentLine);
  }

  return lines.length ? lines : [""];
};

const getValue = (obj, keys, fallback = "") => {
  for (const key of keys) {
    if (obj && typeof obj[key] !== "undefined" && obj[key] !== null && obj[key] !== "") {
      return obj[key];
    }
  }
  return fallback;
};

/**
 * Generate QR code bitmap for ESC/POS printer
 * Returns bitmap data or null on error
 */
const generateQRCodeBitmap = async (text, size = 200) => {
  try {
    console.log("Generating QR code bitmap...");
    
    // Generate QR code as PNG buffer
    const qrBuffer = await QRCode.toBuffer(text, {
      errorCorrectionLevel: 'M',
      type: 'image/png',
      width: size,
      margin: 1
    });
    
    return qrBuffer;
  } catch (err) {
    console.error("QR bitmap generation failed:", err.message);
    return null;
  }
};

/**
 * Detect print location from items (kitchen, bar, shisha, etc.)
 */
const detectLocationFromItems = (items) => {
  if (!Array.isArray(items) || items.length === 0) return 'kitchen';

  let hasFood = false;
  let hasBar = false;
  let hasShisha = false;

  items.forEach((item) => {
    const itemGroup = String(item?.item_group || item?.itemGroup || item?.group || '').toLowerCase();
    const itemName = String(item?.name || item?.item_name || item?.itemName || '').toLowerCase();
    
    if (itemGroup.includes('shisha') || itemName.includes('shisha')) {
      hasShisha = true;
    } else if (itemGroup.includes('bar') || itemGroup.includes('beverage') || itemName.includes('alcohol')) {
      hasBar = true;
    } else {
      hasFood = true;
    }
  });

  // Priority: if mixed items, kitchen gets all
  if (hasFood || !hasBar && !hasShisha) return 'kitchen';
  if (hasShisha && !hasFood && !hasBar) return 'shisha';
  if (hasBar && !hasFood && !hasShisha) return 'bar';
  
  return 'kitchen';
};

/**
 * Get printer IP for a given location
 */
const getPrinterForLocation = (location) => {
  const loc = String(location || 'kitchen').toLowerCase();
  
  if (loc === 'bar') {
    return {
      ip: process.env.BAR_PRINTER_IP || process.env.KITCHEN_PRINTER_IP || '192.168.1.217',
      port: process.env.BAR_PRINTER_PORT || process.env.KITCHEN_PRINTER_PORT || 9100
    };
  } else if (loc === 'shisha') {
    return {
      ip: process.env.SHISHA_PRINTER_IP || process.env.KITCHEN_PRINTER_IP || '192.168.1.217',
      port: process.env.SHISHA_PRINTER_PORT || process.env.KITCHEN_PRINTER_PORT || 9100
    };
  } else {
    // Default to kitchen
    return {
      ip: process.env.KITCHEN_PRINTER_IP || process.env.CASHIER_PRINTER_IP || '192.168.1.217',
      port: process.env.KITCHEN_PRINTER_PORT || process.env.PRINTER_PORT || 9100
    };
  }
};
const printQRWithFallback = (printer, websiteUrl, onComplete) => {
  // Try 1: Native QR code method
  if (typeof printer.qrcode === "function") {
    try {
      console.log("Attempting native QR code print...");
      printer.qrcode(websiteUrl, 6, "M", 6);
      console.log("✅ Native QR code sent to printer");
      onComplete(true);
      return;
    } catch (nativeQrErr) {
      console.warn("Native QR failed:", nativeQrErr.message);
    }
  }

  // Try 2: Bitmap QR via temp file (more reliable for ESC/POS)
  const tempQrFile = path.join(
    os.tmpdir(),
    `chefmate-qr-${Date.now()}-${Math.random().toString(36).slice(2)}.png`
  );

  QRCode.toFile(
    tempQrFile,
    websiteUrl,
    { errorCorrectionLevel: "M", margin: 1, width: 220 },
    (qrFileErr) => {
      if (!qrFileErr) {
        try {
          escpos.Image.load(tempQrFile, (image) => {
            try {
              if (typeof printer.raster === "function") {
                console.log("Attempting raster QR print...");
                printer.raster(image, "dhdw");
              } else if (typeof printer.image === "function") {
                console.log("Attempting image QR print...");
                printer.image(image, "d24");
              } else if (typeof printer.qrimage === "function") {
                console.log("Attempting qrimage print...");
                printer.qrimage(websiteUrl, () => {});
              } else {
                throw new Error("No image method available");
              }

              console.log("✅ Bitmap QR code sent to printer");
              
              // Clean up temp file
              try {
                fs.unlinkSync(tempQrFile);
              } catch (unlinkErr) {
                console.warn("Failed to clean up temp QR file:", unlinkErr.message);
              }
              
              onComplete(true);
            } catch (imageErr) {
              console.error("Image print error:", imageErr.message);
              // Fall through to text fallback
              fs.unlinkSync(tempQrFile).catch(() => {});
              printer.align("ct").text(websiteUrl);
              onComplete(true);
            }
          });
          return;
        } catch (loadErr) {
          console.error("Image load error:", loadErr.message);
        }
      }

      // Fallback: Print URL as text
      console.log("All QR methods failed, printing URL as text");
      fs.unlink(tempQrFile, () => {}); // Async cleanup, ignore errors
      printer.align("ct").text(websiteUrl);
      onComplete(true);
    }
  );
};

const handlePrintJob = (payload, ack) => {
    console.log("Received print job:", payload);

    const jobId = payload && payload.jobId;
    const table = payload && payload.table;
    const items = (payload && payload.items) || [];
    const total = payload && payload.total;
    const companyName = (payload && payload.companyName) || "Restaurant Name";
    const heading = (payload && payload.heading) || "";
    const rawTarget = (payload && payload.target) || "kitchen";
    const target = String(rawTarget).trim().toLowerCase();

    console.log("Company Name received:", companyName);
    console.log("Target:", target);

    if (!jobId) {
      if (typeof ack === "function") {
        ack({ success: false, jobId: null, message: "jobId is required" });
      }
      return;
    }

    if (!table || items.length === 0) {
      if (typeof ack === "function") {
        ack({ success: false, jobId, message: "Invalid print payload" });
      }
      return;
    }

    // ✅ Check if payload contains multiple printer IPs (multi-location printing)
    const allPrinterIps = payload && (payload.allPrinterIps || payload.printers);
    if (allPrinterIps && Array.isArray(allPrinterIps) && allPrinterIps.length > 1) {
      console.log(`\n🖨️  MULTI-PRINTER MODE: Sending to ${allPrinterIps.length} printers`);
      
      const printResults = [];
      let completedCount = 0;

      allPrinterIps.forEach((printerConfig, idx) => {
        const printerIp = printerConfig.ip || printerConfig.printer_ip;
        const port = parseInt(printerConfig.port || printerConfig.printer_port || "9100", 10);
        const terminalId = printerConfig.terminal_id || printerConfig.terminalId || `Printer-${idx + 1}`;
        const location = printerConfig.location || `Printer ${idx + 1}`;

        console.log(`\n📤 Printer ${idx + 1}/${allPrinterIps.length}: ${terminalId} (${location})`);
        console.log(`   IP: ${printerIp}:${port}`);

        const device = new escpos.Network(printerIp, port);
        const printer = new escpos.Printer(device);

        device.open((err) => {
          if (err) {
            console.error(`❌ Printer connection error for ${terminalId}:`, err.message);
            printResults.push({
              terminal_id: terminalId,
              location: location,
              printer_ip: printerIp,
              success: false,
              error: err.message
            });
            completedCount++;

            // Check if all printers are done
            if (completedCount === allPrinterIps.length) {
              const allSucceeded = printResults.every(r => r.success);
              if (typeof ack === "function") {
                ack({
                  success: allSucceeded,
                  jobId,
                  message: `Sent to ${allPrinterIps.length} printers`,
                  results: printResults
                });
              }
            }
            return;
          }

          try {
            const now = new Date();
            const dateStr = now.toLocaleDateString('en-GB');
            const timeStr = now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
            
            // Simplified print content for multi-printer
            printer
              .align("ct")
              .style("b")
              .size(1, 1)
              .text(companyName)
              .text(heading)
              .text("------------------------")
              .style("normal")
              .size(0, 0)
              .align("lt")
              .text(`Table: ${table}`)
              .text(`Date: ${dateStr}  Time: ${timeStr}`)
              .align("ct")
              .text("------------------------");

            printer.size(0, 0).align("lt");
            items.forEach((item) => {
              // ✅ Properly extract quantity with fallback values and convert to Number
              const quantity = Number(getValue(item, ["quantity", "qty"], 0));
              // ✅ Properly extract item name with fallback values
              const displayName = getValue(item, ["name", "item_name", "itemName"], "Item");
              
              console.log(`   Item: ${quantity}x ${displayName}`);
              printer.text(`${quantity}x ${displayName}`);
            });

            printer.text(" ").text(" ").text(" ");

            if (!heading.toLowerCase().includes("kot") && typeof total !== "undefined") {
              printer.align("ct").text("------------------------");
              printer.style("b").size(0, 0).text(`Total: ${total}`);
            }

            // ✅ Properly close with callback to ensure completion
            printer.cut().close(() => {
              console.log(`✅ Print completed for ${terminalId}`);
              printResults.push({
                terminal_id: terminalId,
                location: location,
                printer_ip: printerIp,
                success: true
              });
              
              completedCount++;

              // Check if all printers are done
              if (completedCount === allPrinterIps.length) {
                const allSucceeded = printResults.every(r => r.success);
                if (typeof ack === "function") {
                  ack({
                    success: allSucceeded,
                    jobId,
                    message: `Sent to ${allPrinterIps.length} printers`,
                    results: printResults
                  });
                }
              }
            });

          } catch (printErr) {
            console.error(`❌ Print error for ${terminalId}:`, printErr.message);
            printResults.push({
              terminal_id: terminalId,
              location: location,
              printer_ip: printerIp,
              success: false,
              error: printErr.message
            });

            completedCount++;

            // Check if all printers are done
            if (completedCount === allPrinterIps.length) {
              const allSucceeded = printResults.every(r => r.success);
              if (typeof ack === "function") {
                ack({
                  success: allSucceeded,
                  jobId,
                  message: `Sent to ${allPrinterIps.length} printers`,
                  results: printResults
                });
              }
            }
          }
        });
      });

      return;
    }

    // ✅ Single printer mode (original behavior)
    console.log("\n🖨️  SINGLE-PRINTER MODE");

    // Priority 1: Use printerIp from payload (sent by backend from database)
    // Priority 2: Fall back to environment variables
    // Priority 3: Default values
    const payloadPrinterIp = payload && (payload.printerIp || payload.printer_ip);
    const payloadPrinterPort = payload && (payload.printerPort || payload.printer_port);

    const cashierIp = process.env.CASHIER_PRINTER_IP || "192.168.1.216";
    const defaultIp = process.env.DEFAULT_PRINTER_IP || cashierIp;
    // If kitchen printer IP is not configured, fall back to default/cashier printer.
    const kitchenIp = process.env.KITCHEN_PRINTER_IP || defaultIp;

    const isCashier = target === "cashier" || target === "counter" || target === "front";
    const isKitchen = target === "kitchen" || target === "kt";
    
    // Use printer IP from payload if available, otherwise use target-based lookup
    let printerIp;
    if (payloadPrinterIp) {
      printerIp = payloadPrinterIp;
      console.log(`✅ Using printer IP from payload: ${printerIp}`);
    } else {
      printerIp = isCashier ? cashierIp : isKitchen ? kitchenIp : defaultIp;
      console.log(`✅ Using printer IP from environment/target: ${printerIp}`);
    }
    
    const port = payloadPrinterPort ? parseInt(payloadPrinterPort, 10) : parseInt(process.env.PRINTER_PORT || "9100", 10);

    console.log("Print target:", rawTarget, "Resolved IP:", printerIp, "Port:", port);
    const terminalId = payload && (payload.terminalId || payload.terminal_id) || "Unknown";
    console.log("Terminal ID:", terminalId);

    const device = new escpos.Network(printerIp, port);
    const printer = new escpos.Printer(device);

    device.open((err) => {
      if (err) {
        console.error("Printer connection error:", err);
        if (typeof ack === "function") {
          ack({
            success: false,
            jobId,
            message: "Printer not connected",
            error: err.message
          });
        }
        return;
      }

      try {
        const now = new Date();
        const dateStr = now.toLocaleDateString('en-GB');
        const timeStr = now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
        const normalizedHeading = String(heading || "").trim().toLowerCase();
        const isKotSlip = normalizedHeading.includes("kot");
        const invoiceHint = String(getValue(payload, ["printType", "type", "documentType", "docType"], "")).toLowerCase();
        const hasBillFields =
          typeof getValue(payload, ["bill_id", "billId", "invoiceNo", "invoice_no"], "") !== "undefined" ||
          typeof getValue(payload, ["payment_mode", "paymentMode", "mode"], "") !== "undefined";
        const isInvoiceBill =
          target === "cashier" &&
          !isKotSlip &&
          (invoiceHint.includes("bill") || invoiceHint.includes("invoice") || hasBillFields);
        const hasShishaKot =
          normalizedHeading.includes("shisha kot") ||
          items.some((item) => {
            const itemName = String(
              (item && (item.name || item.item_name || item.itemName || ""))
            )
              .trim()
              .toLowerCase();
            const itemGroup = String(
              (item && (item.item_group || item.itemGroup || item.group || item.category || ""))
            )
              .trim()
              .toLowerCase();

            return itemName.includes("shisha") || itemGroup.includes("shisha");
          });

        if (isInvoiceBill) {
          const lineWidth = 42;
          const separator = "-".repeat(lineWidth);
          const leftMargin = "  "; // 2 spaces for left margin
          const invoiceNo = getValue(payload, ["invoiceNo", "invoice_no", "bill_id", "billId"], jobId);
          const tableNo = getValue(payload, ["table", "table_number", "tableNo", "tablenumber"], "-");
          const billDate = getValue(payload, ["date", "inv_date", "billDate"], dateStr);
          const billTime = getValue(payload, ["time", "inv_time", "billTime"], now.toLocaleTimeString('en-GB'));
          const paymentMode = getValue(payload, ["payment_mode", "paymentMode", "mode"], "Cash");

          const companyAddress = getValue(payload, ["companyAddress", "address"], process.env.COMPANY_ADDRESS || "");
          const companyPhone = getValue(payload, ["companyPhone", "phone", "phone_number"], process.env.COMPANY_PHONE || "");
          const companyWebsiteRaw = getValue(
            payload,
            ["companyWebsite", "company_website", "website", "web_site", "url"],
            process.env.COMPANY_WEBSITE || ""
          );
          const companyWebsite = String(companyWebsiteRaw || "").trim();
          const websiteUrl = companyWebsite
            ? (/^https?:\/\//i.test(companyWebsite) ? companyWebsite : `https://${companyWebsite}`)
            : "";
          const reviewLabel = /google|g\.page|maps/i.test(websiteUrl)
            ? "Scan for Google Review"
            : "Visit us online";
          const companyTax = getValue(payload, ["companyTaxDetails", "taxDetails", "tax_id", "taxId"], process.env.COMPANY_TAX_DETAILS || "");

          const subtotalAmount = Number(getValue(payload, ["subtotal", "subTotal"], 0));
          const discountType = String(getValue(payload, ["discount_type", "discountType"], "")).toLowerCase();
          const discountValue = Number(getValue(payload, ["discount_value", "discountValue"], 0));
          const discountAmount = Number(getValue(payload, ["discount_amount", "discountAmount"], 0));
          const subtotalAfterDiscountAmount = Number(
            getValue(payload, ["subtotal_afterdiscount", "subtotalAfterDiscount"], subtotalAmount - discountAmount)
          );
          const taxAmount = Number(getValue(payload, ["tax", "taxAmount", "tax_amount"], 0));
          const roundOffAmount = Number(getValue(payload, ["roundoff", "round_off", "roundOff"], 0));
          const grandTotalAmount = Number(
            getValue(payload, ["grand_total", "grandTotal", "net_total", "total"], subtotalAfterDiscountAmount + taxAmount + roundOffAmount)
          );
          const taxPercent = Number(getValue(payload, ["tax_percent", "taxPercent", "tax_rate", "taxRate"], Number.NaN));
          const taxLabel = Number.isNaN(taxPercent) ? "Tax:" : `Tax (${taxPercent}%):`;
          const loyaltySelectedRaw = getValue(payload, ["loyalty_selected", "loyaltySelected"], false);
          const loyaltyRedeemedRaw = getValue(payload, ["loyalty_redeemed", "loyaltyRedeemed"], false);
          const loyaltySelected = toBool(loyaltySelectedRaw);
          const loyaltyRedeemed = toBool(loyaltyRedeemedRaw);
          const loyaltyMemberName = String(getValue(payload, ["loyalty_member_name"], "") || "").trim();
          const loyaltyMemberContact = String(getValue(payload, ["loyalty_member_contact"], "") || "").trim();
          const loyaltyOfferName = String(getValue(payload, ["loyalty_offer_name"], "") || "").trim();
          const loyaltyOfferType = String(getValue(payload, ["loyalty_offer_type"], "") || "").trim().toUpperCase();
          const loyaltyPointsUsed = Number(getValue(payload, ["loyalty_points_used"], 0));
          const loyaltyDiscountValue = Number(getValue(payload, ["loyalty_discount_value"], 0));
          const loyaltyFreeItem = String(getValue(payload, ["loyalty_free_item"], "") || "").trim();
          const loyaltyPointsBalance = Number(getValue(payload, ["loyalty_points_balance"], 0));
          const loyaltyQrUrl = String(getValue(payload, ["loyalty_qr_url", "loyaltyQrUrl"], "") || "").trim();
          const loyaltyQrNote = String(getValue(payload, ["loyalty_qr_note", "loyaltyQrNote"], "") || "").trim();
          const hasLoyaltyData = Boolean(
            loyaltyMemberName ||
            loyaltyMemberContact ||
            loyaltyQrUrl ||
            loyaltyRedeemed ||
            loyaltyPointsBalance > 0 ||
            loyaltyPointsUsed > 0
          );

          printer.align("ct").style("b").size(1, 1).text(companyName);
          printer.style("normal").size(0, 0);
          if (companyAddress) {
            wrapText(companyAddress, lineWidth).forEach((line) => printer.text(line));
          }
          if (companyPhone) {
            wrapText(companyPhone, lineWidth).forEach((line) => printer.text(line));
          }
          if (companyTax) printer.text(`Tax:- ${companyTax}`);

          printer.text(" ").align("lt");
          printer.text(leftMargin + formatLeftRight(`Invoice No: ${invoiceNo}`, `Table ${tableNo}`, lineWidth - leftMargin.length));
          printer.text(leftMargin + formatLeftRight(`Date: ${billDate}`, `Time: ${billTime}`, lineWidth - leftMargin.length));
          printer.text(leftMargin + `Mode: ${paymentMode}`);
          printer.text(leftMargin + separator);

          printer.style("b");
          printer.text(leftMargin + `${padRight("Item", 20)}${padLeft("Qty", 4)}${padLeft("Rate", 8)}${padLeft("Total", 10)}`);
          printer.style("normal");
          printer.text(leftMargin + separator);

          items.forEach((item) => {
            const itemName = getValue(item, ["name", "item_name", "itemName"], "Item");
            const quantity = Number(getValue(item, ["quantity", "qty"], 0));
            const rate = Number(getValue(item, ["rate", "price", "unit_price", "unitPrice", "total_price"], 0));
            const lineTotal = Number(
              getValue(item, ["total", "total_amount", "lineTotal", "subtotal"], quantity * rate)
            );

            const nameLines = wrapText(itemName, 20);
            nameLines.forEach((nameLine, idx) => {
              const qtyCell = idx === 0 ? padLeft(quantity || 0, 4) : padLeft("", 4);
              const rateCell = idx === 0 ? padLeft(toAmount(rate), 8) : padLeft("", 8);
              const totalCell = idx === 0 ? padLeft(toAmount(lineTotal), 10) : padLeft("", 10);

              printer.text(leftMargin + `${padRight(nameLine, 20)}${qtyCell}${rateCell}${totalCell}`);
            });
          });

          printer.text(leftMargin + separator);
          printer.text(leftMargin + formatLeftRight("Subtotal:", toAmount(subtotalAmount), lineWidth - leftMargin.length));
          if (discountValue > 0 || discountAmount > 0) {
            const discountDisplay =
              discountType.includes("percent") || discountType.includes("percentage")
                ? `${toAmount(discountValue).replace(/\.00$/, "")}%`
                : toAmount(discountAmount || discountValue);
            printer.text(leftMargin + formatLeftRight("Discount:", discountDisplay, lineWidth - leftMargin.length));
            printer.text(leftMargin + formatLeftRight("Subtotal after Discount:", toAmount(subtotalAfterDiscountAmount), lineWidth - leftMargin.length));
          }
          printer.text(leftMargin + formatLeftRight(taxLabel, toAmount(taxAmount), lineWidth - leftMargin.length));
          printer.text(leftMargin + formatLeftRight("Round Off:", toAmount(roundOffAmount), lineWidth - leftMargin.length));
          printer.style("b").text(leftMargin + formatLeftRight("Total Amount:", toAmount(grandTotalAmount), lineWidth - leftMargin.length));
          printer.style("normal").text(leftMargin + "------------------------------------------");

          if (loyaltySelected || hasLoyaltyData) {
            printer.align("ct").text("LOYALTY DETAILS");
            if (loyaltyMemberName) {
              printer.text(`Member: ${loyaltyMemberName}`);
            }
            if (loyaltyMemberContact) {
              printer.text(`Contact: ${loyaltyMemberContact}`);
            }
            if (loyaltyRedeemed) {
              printer.text("*** LOYALTY REWARD REDEEMED ***");
              if (loyaltyOfferName) {
                wrapText(`Offer: ${loyaltyOfferName}`, lineWidth).forEach((line) => printer.text(line));
              }
              if (loyaltyOfferType === "DISCOUNT_AMOUNT" || loyaltyOfferType === "DISCOUNT_PERCENT") {
                printer.text(`Discount Applied: ${toAmount(loyaltyDiscountValue)}`);
              }
              if (loyaltyOfferType === "FREE_ITEM" && loyaltyFreeItem) {
                wrapText(`Free Item: ${loyaltyFreeItem}`, lineWidth).forEach((line) => printer.text(line));
              }
              printer.text(`Points Used: ${loyaltyPointsUsed}`);
            }
            if (loyaltyPointsBalance > 0 || loyaltyRedeemed) {
              printer.text(`Remaining Points: ${loyaltyPointsBalance}`);
            }
            printer.text("------------------------------------------");
          }

          printer.align("ct").text(`Thank you for visiting ${companyName}`);
          if (companyPhone) {
            printer.text(" ");
            printer.text(`Online Order/Home Delivery: ${companyPhone}`);
          }

          const finalizeInvoice = () => {
            printer.align("ct").text("------------------------------------------");
            printer.align("ct").text("Powered by Cloudnet Softwares");
            printer.style("normal").text(" ").text(" ").cut().close();
            if (typeof ack === "function") {
              ack({ success: true, jobId, printerIp });
            }
          };

          const printQrBlock = (title, url, note, done) => {
            printer.text(" ").align("ct");
            if (title) {
              printer.text(title);
            }
            printer.text(" ");

            const printBitmapFallback = (next) => {
              const tempQrFile = path.join(
                os.tmpdir(),
                `chefmate-qr-${Date.now()}-${Math.random().toString(36).slice(2)}.png`
              );

              QRCode.toFile(
                tempQrFile,
                url,
                { errorCorrectionLevel: "M", margin: 1, width: 220 },
                (qrFileErr) => {
                  if (qrFileErr) {
                    console.error("Bitmap QR generation error:", qrFileErr);
                    next();
                    return;
                  }

                  escpos.Image.load(tempQrFile, (image) => {
                    try {
                      if (typeof printer.raster === "function") {
                        printer.raster(image, "dhdw");
                      } else if (typeof printer.image === "function") {
                        printer.image(image, "d24");
                      }
                    } catch (bitmapPrintErr) {
                      console.error("Bitmap QR print error:", bitmapPrintErr);
                    }

                    fs.unlink(tempQrFile, () => {});
                    next();
                  });
                }
              );
            };

            const finishBlock = () => {
              if (note) {
                wrapText(note, lineWidth).forEach((line) => printer.text(line));
              }
              done();
            };

            if (!url) {
              finishBlock();
              return;
            }

            if (typeof printer.qrimage === "function") {
              printer.qrimage(url, (qrErr) => {
                if (qrErr) {
                  console.error("QR image print error:", qrErr);
                  if (typeof printer.qrcode === "function") {
                    try {
                      // Native ESC/POS QR fallback for printers that reject image mode.
                      printer.qrcode(url, 10, "M", 6);
                      printer.text(" ");
                      printer.text(" ");
                      finishBlock();
                      return;
                    } catch (nativeQrErr) {
                      console.error("Native QR print error:", nativeQrErr);
                    }
                  }
                  printBitmapFallback(() => {
                    printer.text(" ");
                    printer.text(" ");
                    finishBlock();
                  });
                  return;
                }
                printer.text(" ");
                printer.text(" ");
                finishBlock();
              });
            } else if (typeof printer.qrcode === "function") {
              try {
                // Use a higher QR version for longer URLs to reduce overflow failures.
                printer.qrcode(url, 10, "M", 6);
                printer.text(" ");
                printer.text(" ");
                finishBlock();
                return;
              } catch (nativeQrErr) {
                console.error("Native QR print error:", nativeQrErr);
              }
              printBitmapFallback(() => {
                printer.text(" ");
                printer.text(" ");
                finishBlock();
              });
            } else {
              console.error("QR rendering is not available on this ESC/POS setup");
              printBitmapFallback(() => {
                printer.text(" ");
                printer.text(" ");
                finishBlock();
              });
            }
          };

          const qrBlocks = [];
          if (loyaltyQrUrl) {
            qrBlocks.push({
              title: "Check Your Loyalty Points",
              url: loyaltyQrUrl,
              note: loyaltyQrNote || "Scan QR to view loyalty points and history"
            });
          }
          if (websiteUrl) {
            qrBlocks.push({
              title: reviewLabel,
              url: websiteUrl,
              note: ""
            });
          }

          const printQrBlocksSequentially = (blocks, index = 0) => {
            if (index >= blocks.length) {
              finalizeInvoice();
              return;
            }

            const block = blocks[index];
            printQrBlock(block.title, block.url, block.note, () => {
              printQrBlocksSequentially(blocks, index + 1);
            });
          };

          printQrBlocksSequentially(qrBlocks);
          return;
        }

        printer
          .align("ct")
          .style("b")
          .size(1, 1)
          .text(companyName)
          .text(heading)
          .text("------------------------")
          .style("normal")
          .size(0, 0)
          .align("lt")
          .text(`Table: ${table}`)
          .text(`Date: ${dateStr}  Time: ${timeStr}`)
          .align("ct")
          .text("------------------------");

        // Items with smaller text
        printer.size(0, 0).align("lt");
        items.forEach((item) => {
          const displayName = (item && (item.name || item.item_name || item.itemName)) || "Item";
          const wrappedNameLines = wrapText(displayName, 26);
          wrappedNameLines.forEach((line, idx) => {
            if (idx === 0) {
              printer.text(`${item.quantity}x ${line}`);
            } else {
              printer.text(`   ${line}`);
            }
          });
        });
        printer.text(" ");
        printer.text(" ");
        printer.text(" ");

        if (!isKotSlip && typeof total !== "undefined") {
          printer.align("ct").text("------------------------");
          printer.style("b").size(0, 0).text(`Total: ${total}`);
        }

        printer.cut();

        if (hasShishaKot) {
          const shishaStart = new Date();
          const shishaEnd = new Date(shishaStart.getTime() + 60 * 60 * 1000);
          const shishaDate = shishaStart.toLocaleDateString('en-GB');
          const shishaStartTime = shishaStart.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
          const shishaEndTime = shishaEnd.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });

          printer
            .align("ct")
            .style("b")
            .size(1, 1)
            .text("SHISHA TIMING SLIP")
            .text("------------------------")
            .style("normal")
            .size(0, 0)
            .align("lt")
            .text(formatLeftRight(`Table No: ${table}`, `Date: ${shishaDate}`))
            .text(`Start Time: ${shishaStartTime}`)
            .text(`End Time: ${shishaEndTime}`)
            .text("------------------------")
            .text(`Thanks for choosing ${companyName}`)
            .text("Wifi Name :")
            .text("Wifi Password:")
            .text(" ")
            .text(" ")
            .text(" ")
            .cut();
        }

        printer.close();

        if (typeof ack === "function") {
          ack({ success: true, jobId, printerIp });
        }
      } catch (printError) {
        console.error("Print error:", printError);
        if (typeof ack === "function") {
          ack({
            success: false,
            jobId,
            message: "Print failed",
            error: printError.message
          });
        }
      }
    });
};

io.on("connection", (socket) => {
  console.log("Cloud agent connected:", socket.id);

  socket.on("print", handlePrintJob);

  socket.on("disconnect", (reason) => {
    console.log("Cloud agent disconnected:", reason);
  });
});

/**
 * REST API Route: Print KOT via HTTP (for frontend)
 */
app.post("/print-kot", async (req, res) => {
  try {
    console.log('📥 Received print-kot request');
    const { printer_ip, printer_port, data, type, heading, table, items, total, companyName } = req.body || {};

    const payloadData = (data && typeof data === "object") ? data : {};
    const finalHeading = heading || payloadData.heading || "KITCHEN KOT";
    const finalTable = table || payloadData.table || payloadData.table_number || "-";
    const finalItems = Array.isArray(items)
      ? items
      : (Array.isArray(payloadData.items) ? payloadData.items : []);
    const finalTotal = Number(total ?? payloadData.total ?? 0);
    const finalCompanyName = companyName || payloadData.companyName || "Restaurant";
    const jobId = req.body?.jobId || payloadData.jobId || `kot-${Date.now()}`;
    
    if (finalItems.length === 0) {
      return res.status(400).json({
        success: false,
        message: "No items to print"
      });
    }

    // 🎯 Use provided printer IP, or detect from items as fallback
    let finalPrinterIp = printer_ip;
    let finalPrinterPort = printer_port;

    if (!finalPrinterIp || !finalPrinterPort) {
      console.log("ℹ️  No printer IP provided, detecting from items...");
      const detectedLocation = detectLocationFromItems(finalItems);
      const targetPrinter = getPrinterForLocation(detectedLocation);
      finalPrinterIp = targetPrinter.ip;
      finalPrinterPort = targetPrinter.port;
      console.log(`📍 Detected location: ${detectedLocation}`);
    }

    console.log(`🖨️ Routing KOT to printer: ${finalPrinterIp}:${finalPrinterPort}`);

    const device = new escpos.Network(finalPrinterIp, Number(finalPrinterPort));
    const printer = new escpos.Printer(device);

    return device.open((err) => {
      if (err) {
        console.error("Printer connection error (REST):", err.message);
        return res.status(500).json({
          success: false,
          message: "Printer not connected",
          error: err.message
        });
      }

      try {
        const now = new Date();
        const dateStr = now.toLocaleDateString('en-GB');
        const timeStr = now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });

        const lineWidth = 42;
        const separator = "-".repeat(lineWidth);
        const leftMargin = "  ";
        const invoiceHint = String(getValue(req.body, ["printType", "type", "documentType", "docType"], type || "")).toLowerCase();
        const isInvoiceBill =
          invoiceHint.includes("bill") ||
          invoiceHint.includes("invoice") ||
          String(finalHeading || "").toLowerCase().includes("invoice");

        if (isInvoiceBill) {
          const invoiceNo = getValue(req.body, ["invoiceNo", "invoice_no", "bill_id", "billId"], jobId);
          const rawTableNo = getValue(req.body, ["table", "table_number", "tableNo", "tablenumber"], finalTable || "-");
          const tableNo = String(rawTableNo || "-").replace(/^table\s*/i, "").trim() || "-";
          const billDate = getValue(req.body, ["date", "inv_date", "billDate"], dateStr);
          const billTime = getValue(req.body, ["time", "inv_time", "billTime"], timeStr);
          const paymentMode = getValue(req.body, ["payment_mode", "paymentMode", "mode"], "Cash");

          const companyAddress = getValue(req.body, ["companyAddress", "address"], process.env.COMPANY_ADDRESS || "");
          const companyPhone = getValue(req.body, ["companyPhone", "phone", "phone_number"], process.env.COMPANY_PHONE || "");
          const companyWebsiteRaw = getValue(
            req.body,
            ["companyWebsite", "company_website", "website", "web_site", "url"],
            process.env.COMPANY_WEBSITE || ""
          );
          const companyWebsite = String(companyWebsiteRaw || "").trim();
          const websiteUrl = companyWebsite
            ? (/^https?:\/\//i.test(companyWebsite) ? companyWebsite : `https://${companyWebsite}`)
            : "";
          const reviewLabel = /google|g\.page|maps/i.test(websiteUrl)
            ? "Scan for Google Review"
            : "Visit us online";
          const companyTax = getValue(req.body, ["companyTaxDetails", "taxDetails", "tax_id", "taxId"], process.env.COMPANY_TAX_DETAILS || "");

          const subtotalAmount = Number(getValue(req.body, ["subtotal", "subTotal"], 0));
          const discountType = String(getValue(req.body, ["discount_type", "discountType"], "")).toLowerCase();
          const discountValue = Number(getValue(req.body, ["discount_value", "discountValue"], 0));
          const discountAmount = Number(getValue(req.body, ["discount_amount", "discountAmount"], 0));
          const subtotalAfterDiscountAmount = Number(
            getValue(req.body, ["subtotal_afterdiscount", "subtotalAfterDiscount"], subtotalAmount - discountAmount)
          );
          const taxAmount = Number(getValue(req.body, ["tax", "taxAmount", "tax_amount"], 0));
          const roundOffAmount = Number(getValue(req.body, ["roundoff", "round_off", "roundOff"], 0));
          const grandTotalAmount = Number(
            getValue(req.body, ["grand_total", "grandTotal", "net_total", "total"], subtotalAfterDiscountAmount + taxAmount + roundOffAmount)
          );
          const taxPercent = Number(getValue(req.body, ["tax_percent", "taxPercent", "tax_rate", "taxRate"], Number.NaN));
          const taxLabel = Number.isNaN(taxPercent) ? "Tax:" : `Tax (${taxPercent}%):`;

          printer.align("ct").style("b").size(1, 1).text(finalCompanyName);
          printer.style("normal").size(0, 0);
          if (companyAddress) {
            wrapText(companyAddress, lineWidth).forEach((line) => printer.text(line));
          }
          if (companyPhone) {
            wrapText(companyPhone, lineWidth).forEach((line) => printer.text(line));
          }
          if (companyTax) printer.text(`Tax:- ${companyTax}`);

          printer.text(" ").align("lt");
          printer.text(leftMargin + formatLeftRight(`Invoice No: ${invoiceNo}`, `Table ${tableNo}`, lineWidth - leftMargin.length));
          printer.text(leftMargin + formatLeftRight(`Date: ${billDate}`, `Time: ${billTime}`, lineWidth - leftMargin.length));
          printer.text(leftMargin + `Mode: ${paymentMode}`);
          printer.text(leftMargin + separator);

          printer.style("b");
          printer.text(leftMargin + `${padRight("Item", 20)}${padLeft("Qty", 4)}${padLeft("Rate", 8)}${padLeft("Total", 10)}`);
          printer.style("normal");
          printer.text(leftMargin + separator);

          finalItems.forEach((item) => {
            const itemName = getValue(item, ["name", "item_name", "itemName"], "Item");
            const quantity = Number(getValue(item, ["quantity", "qty"], 0));
            const rate = Number(getValue(item, ["rate", "price", "unit_price", "unitPrice", "total_price"], 0));
            const lineTotal = Number(
              getValue(item, ["total", "total_amount", "lineTotal", "subtotal", "total_price"], quantity * rate)
            );

            const nameLines = wrapText(itemName, 20);
            nameLines.forEach((nameLine, idx) => {
              const qtyCell = idx === 0 ? padLeft(quantity || 0, 4) : padLeft("", 4);
              const rateCell = idx === 0 ? padLeft(toAmount(rate), 8) : padLeft("", 8);
              const totalCell = idx === 0 ? padLeft(toAmount(lineTotal), 10) : padLeft("", 10);

              printer.text(leftMargin + `${padRight(nameLine, 20)}${qtyCell}${rateCell}${totalCell}`);
            });
          });

          printer.text(leftMargin + separator);
          printer.text(leftMargin + formatLeftRight("Subtotal:", toAmount(subtotalAmount), lineWidth - leftMargin.length));
          if (discountValue > 0 || discountAmount > 0) {
            const discountDisplay =
              discountType.includes("percent") || discountType.includes("percentage")
                ? `${toAmount(discountValue).replace(/\.00$/, "")}%`
                : toAmount(discountAmount || discountValue);
            printer.text(leftMargin + formatLeftRight("Discount:", discountDisplay, lineWidth - leftMargin.length));
            printer.text(leftMargin + formatLeftRight("Subtotal after Discount:", toAmount(subtotalAfterDiscountAmount), lineWidth - leftMargin.length));
          }
          printer.text(leftMargin + formatLeftRight(taxLabel, toAmount(taxAmount), lineWidth - leftMargin.length));
          printer.text(leftMargin + formatLeftRight("Round Off:", toAmount(roundOffAmount), lineWidth - leftMargin.length));
          printer.style("b").text(leftMargin + formatLeftRight("Total Amount:", toAmount(grandTotalAmount), lineWidth - leftMargin.length));
          printer.style("normal").text(leftMargin + "------------------------------------------");
          printer.align("ct").text(`Thank you for visiting ${finalCompanyName}`);
          if (companyPhone) {
            printer.text(" ");
            printer.text(`Online Order/Home Delivery: ${companyPhone}`);
          }

          const finalizeInvoice = () => {
            printer.align("ct").text("------------------------------------------");
            printer.align("ct").text("Powered by Cloudnet Softwares");
            printer.style("normal").text(" ").text(" ").cut().close(() => {
              res.json({
                success: true,
                message: "Invoice printed successfully",
                data: {
                  jobId,
                  printer_ip: finalPrinterIp,
                  printer_port: finalPrinterPort,
                  location: detectedLocation,
                  type: type || 'INVOICE'
                }
              });
            });
          };

          if (websiteUrl) {
            printer.text(" ").align("ct").text(reviewLabel).text(" ");
            printQRWithFallback(printer, websiteUrl, finalizeInvoice);
          } else {
            finalizeInvoice();
          }
          return;
        }

        printer
          .align("ct")
          .style("b")
          .size(1, 1)
          .text(finalCompanyName)
          .style("normal")
          .font("a")
          .size(0, 0)
          .text(finalHeading)
          .text("------------------------")
          .size(0, 0)
          .align("lt")
          .text(`Table: ${finalTable}`)
          .text(`Date: ${dateStr}  Time: ${timeStr}`)
          .align("ct")
          .text("------------------------")
          .align("lt");

        finalItems.forEach((item) => {
          const qty = Number(getValue(item, ["quantity", "qty"], 0));
          const name = getValue(item, ["name", "item_name", "itemName"], "Item");
          printer.text(`${qty}x ${name}`);
        });

        if (!String(finalHeading).toLowerCase().includes("kot")) {
          printer.align("ct").text("------------------------");
          printer.style("b").text(`Total: ${toAmount(finalTotal)}`);
          printer.style("normal");
        }

        return printer
          .text(" ")
          .text(" ")
          .cut()
          .close(() => {
            res.json({
              success: true,
              message: "KOT printed successfully",
              data: {
                jobId,
                printer_ip: finalPrinterIp,
                printer_port: finalPrinterPort,
                location: detectedLocation,
                type: type || 'KOT'
              }
            });
          });
      } catch (printError) {
        console.error("Print-kot error (REST):", printError);
        return res.status(500).json({
          success: false,
          message: "Print failed",
          error: printError.message
        });
      }
    });

  } catch (error) {
    console.error("Print-kot error:", error);
    res.status(500).json({
      success: false,
      message: "Error processing print job"
    });
  }
});
/**
 * Health check endpoint
 */
app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    status: "ok",
    service: "chefmate-local-agent"
  });
});

const PORT = process.env.LOCAL_AGENT_PORT || 7001;
server.listen(PORT, () => {
  console.log(`\n✅ Local Printing Agent running on http://127.0.0.1:${PORT}`);
  console.log(`   REST API: http://127.0.0.1:${PORT}/print-kot`);
  console.log(`   Health: http://127.0.0.1:${PORT}/api/health\n`);
});
