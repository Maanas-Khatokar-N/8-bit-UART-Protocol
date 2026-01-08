# 📡 8-bit UART Protocol (Verilog)

![Language](https://img.shields.io/badge/Language-Verilog-blue) ![Tools](https://img.shields.io/badge/Tools-Icarus%20Verilog%20%7C%20GTKWave-green)

## 📖 Overview
This repository contains a Register Transfer Level (RTL) implementation of a **Universal Asynchronous Receiver-Transmitter (UART)** Protocol. The design is implemented in Verilog HDL and features a fully functional Transmitter (TX), a Receiver (RX) with **16x oversampling** for noise immunity, and a configurable Baud Rate Generator.

The project is designed to operate at **9600 bps** using a **50 MHz** system clock, making it suitable for FPGA implementation and reliable serial communication.

---

## ⚙️ Technical Specifications
* **Clock Frequency:** 50 MHz
* **Baud Rate:** 9600 bps
* **Data Bits:** 8 bits
* **Stop Bits:** 1 bit
* **Parity:** None (8N1)
* **Oversampling:** 16x (Receiver)

---

## 📂 File Structure

| File Name | Description |
| :--- | :--- |
| `uart_top.v` | Top-level module connecting the Baud Generator, TX, and RX modules. |
| `transmitter.v` | Serializes parallel data for transmission using a 4-state FSM. |
| `receiver.v` | Deserializes incoming data with oversampling logic using a 3-state FSM. |
| `baudRate_generator.v` | Generates TX and RX enable ticks based on clock division. |
| `uart_tb.v` | Self-checking testbench for verification and waveform generation. |

---

## 🧠 Module Details

### 1. Baud Rate Generator (`baudRate_generator.v`)
Handles the timing for data transmission and reception.
* **Calculations:**
    * **TX Sample Rate:** 50MHz / 9600 = 5208 clocks per bit.
    * **RX Sample Rate:** 50MHz / (9600 x 16) = 325 clocks per sample (16x oversampling).
* **Outputs:** Generates `tx_enable` and `rx_enable` pulses.

### 2. Transmitter (`transmitter.v`)
Converts 8-bit parallel data into a serial stream. It utilizes a Finite State Machine (FSM) with the following states:
* `idle_state` (00): Waiting for `write_en` signal.
* `start_state` (01): Pulls the line low to initiate transmission (start bit).
* `data_state` (10): Shifts out 8 data bits sequentially (LSB first).
* `stop_state` (11): Pulls the line high to end transmission (stop bit).

### 3. Receiver (`receiver.v`)
Captures serial data and converts it back to 8-bit parallel format.
* **Oversampling:** Checks the incoming line 16 times per bit duration. It captures the bit value at the **8th sample** (middle of the bit) to ensure data integrity.
* **States:** `start_state` (01), `data_out_state` (10), and `stop_state` (11).

### 4. Top Module (`uart_top.v`)
Acts as a loopback wrapper for testing:
* Instantiates `baudRate_generator`, `transmitter`, and `receiver`.
* Internally connects the `tx` output wire (`tx_temp`) directly to the `rx` input wire for loopback testing.

---

## 📊 Simulation & Waveforms

The project includes a testbench (`uart_tb.v`) that simulates the entire UART system.

### Test Sequence:
The testbench applies the following stimuli:
1. **Reset:** System reset applied for initial stabilization.
2. **Byte 1:** Sends `0x12` and waits for reception.
3. **Byte 2:** Sends `0x50` and waits for reception.
4. **Byte 3:** Sends `0x77` and waits for reception.

### Waveform Result:
*(`![Waveform](uart_waveform.png)`)*

> **Note:** The simulation generates a `uart_waveform.vcd` file which can be viewed using GTKWave.

---

## 🚀 How to Run

### Using Icarus Verilog
1. **Compile the design:**
```bash
   iverilog -o uart_sim uart_tb.v uart_top.v transmitter.v receiver.v baudRate_generator.v
```
2. **Run the simulation:**
```bash
   vvp uart_sim
```
3. **View Waveforms:**
```bash
   gtkwave uart_waveform.vcd
```

---
