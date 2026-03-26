# Chefmate Local Agent

Local WebSocket server that receives print jobs from the cloud node agent.

## Run

1. Install deps:
   - `npm install`
2. Start:
   - `npm start`

## Environment

- `LOCAL_AGENT_PORT` (default: 5010)
- `KITCHEN_PRINTER_IP` (default: 192.168.1.217)
- `CASHIER_PRINTER_IP` (default: 192.168.1.216)
- `DEFAULT_PRINTER_IP` (default: kitchen IP)
- `PRINTER_PORT` (default: 9100)

## Notes

- Send `target: "kitchen"` or `target: "cashier"` in the payload to select the printer.
