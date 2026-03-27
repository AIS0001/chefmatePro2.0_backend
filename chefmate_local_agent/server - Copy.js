const http = require("http");
const express = require("express");
const { Server } = require("socket.io");
const escpos = require("escpos");

escpos.Network = require("escpos-network");

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*"
  }
});

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

io.on("connection", (socket) => {
  console.log("Cloud agent connected:", socket.id);

  socket.on("print", (payload, ack) => {
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

    const kitchenIp = process.env.KITCHEN_PRINTER_IP || "192.168.1.217";
    const cashierIp = process.env.CASHIER_PRINTER_IP || "192.168.1.216";
    const defaultIp = process.env.DEFAULT_PRINTER_IP || cashierIp;

    const isCashier = target === "cashier" || target === "counter" || target === "front";
    const isKitchen = target === "kitchen" || target === "kt";
    const printerIp = isCashier ? cashierIp : isKitchen ? kitchenIp : defaultIp;
    const port = parseInt(process.env.PRINTER_PORT || "9100", 10);

    console.log("Print target:", rawTarget, "Resolved IP:", printerIp);

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
          const companyWebsiteRaw = getValue(payload, ["companyWebsite", "website"], "");
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
          printer.align("ct").text(`Thank you for visiting ${companyName}`);
          if (companyPhone) {
            printer.text(" ");
            printer.text(`Online Order/Home Delivery: ${companyPhone}`);
          }
          const finalizeInvoice = () => {
            printer.align("ct").text("Powered by Cloudnet Softwares");
            printer.style("normal").text(" ").text(" ").cut().close();
            if (typeof ack === "function") {
              ack({ success: true, jobId, printerIp });
            }
          };

          if (websiteUrl && typeof printer.qrimage === "function") {
            printer.text(" ").align("ct").text(reviewLabel).text(" ");
            printer.qrimage(websiteUrl, (qrErr) => {
              if (qrErr) {
                console.error("QR print error:", qrErr);
                printer.align("ct").text(websiteUrl);
              }
              finalizeInvoice();
            });
          } else if (websiteUrl) {
            printer.text(" ").align("ct").text(reviewLabel).text(" ").text(websiteUrl);
            finalizeInvoice();
          } else {
            finalizeInvoice();
          }
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
  });

  socket.on("disconnect", (reason) => {
    console.log("Cloud agent disconnected:", reason);
  });
});

const PORT = process.env.LOCAL_AGENT_PORT || 5010;
server.listen(PORT, () => {
  console.log(`Local agent listening on port ${PORT}`);
});
