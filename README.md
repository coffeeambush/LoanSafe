# LoanSafe

**Created by Richard Snyder as part of my Data Analytics Master's Program*
## 👤 Author
Richard Snyder  
[LinkedIn](www.linkedin.com/in/richard-snyder-b18995266) | [GitHub](https://github.com/coffeeambush)


LoanSafe is a neural network model designed to predict safe loan amounts based on customer characteristics and flag potentially high-risk loan requests for further review. The goal is to help lenders reduce default risk and improve decision-making by leveraging predictive analytics.

---

## 📊 Project Overview

- Utilizes a regression-based neural network model (not classification)
- Predicts loan amount a customer is likely to request
- Flags loans that significantly exceed expected values
- Built using R and tested on provided synthetic datasets

---

## ⚙️ Model Metrics

- **TSS:** 99  
- **RSS:** 54  
- **R²:** 0.45  
> (Note: Model reached 0.97 R² when including the `installment` variable, but this was excluded due to data leakage as it was derived from the target.)

---

## 📁 Included Data Files

- `CreditAmount_Data.csv` – Main training dataset  
- `CreditAmount_verify.csv` – Test/validation dataset  
- `CreditAmount_DataDictionary.csv` – Definitions of all columns  

*Note: These datasets are fictional and were provided for educational use only.*

---

## 📌 Next Steps & Improvements

- Replace static `.csv` loading with dynamic input pipeline
- Expand feature set (e.g., credit score, income history)
- Periodically retrain model with updated customer data
- Add risk scoring logic and dashboard visualizations (optional future work)
- 
---

## 🎤 Presentation (with Audio)
- `Snyder_Richard_Capstone_Presentation.pptx` — Includes recorded narration on each slide. Best viewed in PowerPoint with audio enabled.

---

## 🔒 License

This project is licensed under the MIT License. See `LICENSE` for details.
