# 🛠️ Troubleshooting Guide

> **Solutions to common issues in Clinical Data Analysis with R** 🔧

This guide helps you resolve common problems you might encounter while working through the tutorial series.

---

## 📦 Package Installation Issues

### "Package not available" Error
**Problem:** `Error in install.packages() : package 'package_name' is not available for this version of R`

**Solutions:**
1. **Update R to the latest version**
   ```r
   # Check current version
   R.version.string
   # Download latest from https://www.r-project.org/
   ```

2. **Try installing from CRAN with specific repository**
   ```r
   install.packages("package_name", repos = "https://cran.rstudio.com/")
   ```

3. **Install from Bioconductor (for bioinformatics packages)**
   ```r
   if (!require("BiocManager", quietly = TRUE))
       install.packages("BiocManager")
   BiocManager::install("package_name")
   ```

### Package Dependencies Issues
**Problem:** Package installation fails due to missing dependencies

**Solutions:**
1. **Install with dependencies**
   ```r
   install.packages("package_name", dependencies = TRUE)
   ```

2. **Install system dependencies (Linux/Mac)**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev
   
   # macOS (with Homebrew)
   brew install openssl curl libxml2
   ```

---

## 📊 Data Import Issues

### Excel File Not Found
**Problem:** `Error: 'Data/ClinicalData.xlsx' does not exist`

**Solutions:**
1. **Check working directory**
   ```r
   getwd()  # Should show path to your tutorial folder
   list.files()  # Should show Data/ folder
   ```

2. **Set correct working directory**
   ```r
   setwd("/path/to/your/Tables_R_Tutorial")
   ```

3. **Use absolute path**
   ```r
   data <- read_excel("/full/path/to/Data/ClinicalData.xlsx")
   ```

### Excel File Format Issues
**Problem:** `Error: zip file cannot be opened`

**Solutions:**
1. **Check file format**
   - Ensure file is `.xlsx` (not `.xls`)
   - Try saving as `.xlsx` in Excel

2. **Alternative import methods**
   ```r
   # Try different readxl functions
   data <- read_xlsx("Data/ClinicalData.xlsx")
   # or
   data <- read_excel("Data/ClinicalData.xlsx", sheet = 1)
   ```

---

## 🎨 Plotting Issues

### "Object not found" in ggplot
**Problem:** `Error: object 'variable_name' not found`

**Solutions:**
1. **Check variable names**
   ```r
   names(data)  # List all column names
   colnames(data)  # Alternative way
   ```

2. **Check data structure**
   ```r
   str(data)  # See variable types and names
   head(data)  # View first few rows
   ```

3. **Use correct variable names**
   ```r
   # If column is named "Age" not "age"
   ggplot(data, aes(x = Age)) + geom_histogram()
   ```

### Plot Not Displaying
**Problem:** Plot appears blank or doesn't show

**Solutions:**
1. **Check for missing data**
   ```r
   sum(is.na(data$variable_name))
   ```

2. **Remove NA values**
   ```r
   ggplot(data, aes(x = variable_name)) + 
     geom_histogram(na.rm = TRUE)
   ```

3. **Check plot device**
   ```r
   dev.off()  # Clear plot device
   # Then recreate plot
   ```

---

## 📈 Statistical Analysis Issues

### Survival Analysis Errors
**Problem:** `Error in Surv() : invalid survival times`

**Solutions:**
1. **Check survival data format**
   ```r
   # Time should be numeric, event should be 0/1
   str(data$OS)  # Should be numeric
   str(data$Censor)  # Should be numeric
   ```

2. **Remove invalid survival times**
   ```r
   # Remove negative or missing times
   data_clean <- data[!is.na(data$OS) & data$OS >= 0, ]
   ```

3. **Convert to proper format**
   ```r
   data$OS <- as.numeric(data$OS)
   data$Censor <- as.numeric(data$Censor)
   ```

### Model Convergence Issues
**Problem:** `Warning: glm.fit: algorithm did not converge`

**Solutions:**
1. **Check for perfect separation**
   ```r
   table(data$outcome, data$predictor)
   ```

2. **Increase maximum iterations**
   ```r
   model <- glm(outcome ~ predictor, data = data, 
                control = list(maxit = 1000))
   ```

3. **Check for multicollinearity**
   ```r
   library(car)
   vif(model)
   ```

---

## 🔧 R Environment Issues

### Memory Issues
**Problem:** `Error: cannot allocate vector of size X Mb`

**Solutions:**
1. **Clear workspace**
   ```r
   rm(list = ls())  # Remove all objects
   gc()  # Garbage collection
   ```

2. **Increase memory limit (Windows)**
   ```r
   memory.limit(size = 8000)  # Set to 8GB
   ```

3. **Use data.table for large datasets**
   ```r
   library(data.table)
   data <- fread("large_file.csv")
   ```

### RStudio Issues
**Problem:** RStudio crashes or becomes unresponsive

**Solutions:**
1. **Restart R session**
   - Session → Restart R (Ctrl+Shift+F10)

2. **Clear RStudio cache**
   - Tools → Global Options → General → Clear cache

3. **Update RStudio**
   - Download latest version from https://posit.co/download/rstudio-desktop/

---

## 📋 Common Error Messages & Solutions

### "Object of type 'closure' is not subsettable"
**Cause:** Trying to use `$` on a function instead of data frame
**Solution:**
```r
# Wrong
data$function_name

# Correct
data$column_name
```

### "Replacement has X rows, data has Y rows"
**Cause:** Trying to assign vector of wrong length
**Solution:**
```r
# Check lengths
length(new_values)
nrow(data)

# Ensure they match
data$new_column <- new_values[1:nrow(data)]
```

### "Non-numeric argument to binary operator"
**Cause:** Trying to perform math on non-numeric data
**Solution:**
```r
# Convert to numeric
data$column <- as.numeric(data$column)
```

---

## 🆘 Getting Additional Help

### R Help Resources
1. **Built-in help**
   ```r
   ?function_name
   help(function_name)
   ```

2. **Search help**
   ```r
   help.search("topic")
   apropos("keyword")
   ```

3. **Online resources**
   - [R Documentation](https://www.r-project.org/help.html)
   - [Stack Overflow R tag](https://stackoverflow.com/questions/tagged/r)
   - [RStudio Community](https://community.rstudio.com/)

### Package-Specific Help
- **ggplot2**: [ggplot2.tidyverse.org](https://ggplot2.tidyverse.org/)
- **dplyr**: [dplyr.tidyverse.org](https://dplyr.tidyverse.org/)
- **survival**: [CRAN survival package](https://cran.r-project.org/web/packages/survival/)

### Debugging Tips
1. **Use browser() for debugging**
   ```r
   browser()  # Pause execution here
   ```

2. **Check intermediate results**
   ```r
   print(head(data))
   str(data)
   ```

3. **Use tryCatch for error handling**
   ```r
   result <- tryCatch({
     # Your code here
   }, error = function(e) {
     print(paste("Error:", e$message))
     return(NULL)
   })
   ```

---

## 📞 Still Need Help?

If you're still experiencing issues:

1. **Check the error message carefully** - it often contains clues
2. **Search online** - many R errors have been solved before
3. **Ask in R communities** - Stack Overflow, RStudio Community, Reddit r/rstats
4. **Provide context** - include your R version, package versions, and reproducible example

**Remember:** Every error is a learning opportunity! 🎓

---

*Last updated: 2024* 