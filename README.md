# VLSI Architectures for Signal Processing and Machine Learning

This repository contains the lab exercises and projects completed as part of the **VLSI Architectures for Signal Processing and Machine Learning** course.  

---

## 🧩 Lab Exercises

### **Lab 1: 4-tap FIR Filter**
- Implemented a **4-tap FIR Filter** using fixed-point Q(1.15) representation in Verilog.
- **Features:**
  - Compared multiple rounding strategies (after every operation / after adders / final output).
  - Verified output against MATLAB golden reference.

---

### **Lab 2: Sum of N Natural Numbers**
- Designed a Verilog module to compute the **sum of first N natural numbers** using iterative hardware logic.
- **Highlights:**
  - Implemented multiple architectures using datapath-only and FSM-based control.
  - Designed 2-state and 3-state FSM versions for safe operation.
  - Added ACK-based DONE state handling.
  - Implemented a modular datapath + control split architecture.
---

### **Lab 3: GCD using Euclid’s Algorithm**
- Implemented **Euclid’s GCD algorithm** for two natural numbers using Verilog.
- **Highlights:**
  - Designed FSM-based GCD hardware with IDLE–BUSY–DONE states.
  - Implemented architectures using enable registers and MUX-based register inputs.
  - Developed an advanced design supporting independent arrival of operands using a 5-state FSM.
---

## 🧪 Experiment References
- [**Lab 1 – 4-tap FIR Filter**](https://github.com/KaushikBalaji/vlsi_architecture_lab/tree/main/Ex1)  
- [**Lab 2 – Sum of N Natural Numbers**](https://github.com/KaushikBalaji/vlsi_architecture_lab/tree/main/Ex2)  
- [**Lab 3 – GCD using Euclid’s Algorithm**](https://github.com/KaushikBalaji/vlsi_architecture_lab/tree/main/Ex3)  
---

## 👨‍💻 Authors
**Kaushik Balaji**, [**D. Priyesh Narayana**](https://www.linkedin.com/in/priyesh-narayana-54a7982a4/)  
M.Tech – System-on-Chip Design (SoCD)  
IIT Palakkad  

---
