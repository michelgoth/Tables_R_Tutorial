# 🧪 Exercise 1: Basic Data Analysis

> **Practice your skills after completing Lesson 1** 📊

This exercise will help you reinforce the concepts learned in Lesson 1 and prepare you for more advanced topics.

---

## 📋 Exercise Overview

**Duration:** 45-60 minutes  
**Difficulty:** Beginner  
**Prerequisites:** Lesson 1 completion  
**Skills Practiced:** Data import, exploration, basic visualization

---

## 🎯 Learning Objectives

By completing this exercise, you will:
- ✅ Import and explore clinical data
- ✅ Create various types of plots
- ✅ Practice data manipulation
- ✅ Interpret basic statistics
- ✅ Customize visualizations

---

## 📊 Dataset Information

We'll use the same `ClinicalData.xlsx` dataset from the main tutorial. This contains information about:
- Patient demographics (Age, Gender)
- Clinical characteristics (Grade, Histology)
- Treatment information (Radiotherapy, Chemotherapy)
- Molecular markers (IDH, 1p19q, MGMT)
- Survival data (OS, Censor)

---

## 🚀 Exercise Tasks

### Task 1: Data Import and Exploration (10 minutes)

1. **Load the required packages:**
   ```r
   library(readxl)
   library(ggplot2)
   library(dplyr)
   ```

2. **Import the data:**
   ```r
   data <- read_excel("Data/ClinicalData.xlsx")
   ```

3. **Explore the data structure:**
   - Use `str(data)` to see variable types
   - Use `summary(data)` to get basic statistics
   - Use `head(data, 10)` to view first 10 rows

4. **Check for missing data:**
   ```r
   # Count missing values in each column
   sapply(data, function(x) sum(is.na(x)))
   ```

**Questions to answer:**
- How many patients are in the dataset?
- Which variables have missing data?
- What are the data types of each variable?

### Task 2: Descriptive Statistics (15 minutes)

1. **Create summary statistics for Age:**
   ```r
   # Calculate mean, median, standard deviation
   mean(data$Age, na.rm = TRUE)
   median(data$Age, na.rm = TRUE)
   sd(data$Age, na.rm = TRUE)
   ```

2. **Create frequency tables:**
   ```r
   # For categorical variables
   table(data$Gender)
   table(data$Grade)
   table(data$IDH_mutation_status)
   ```

3. **Calculate proportions:**
   ```r
   # What proportion of patients are female?
   prop.table(table(data$Gender))
   ```

**Questions to answer:**
- What is the average age of patients?
- What is the most common tumor grade?
- What proportion of patients have IDH mutations?

### Task 3: Basic Visualizations (20 minutes)

1. **Create a histogram of Age:**
   ```r
   ggplot(data, aes(x = Age)) +
     geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
     labs(title = "Age Distribution of Patients", 
          x = "Age (years)", y = "Count") +
     theme_minimal()
   ```

2. **Create a bar plot of tumor grades:**
   ```r
   ggplot(data, aes(x = Grade)) +
     geom_bar(fill = "coral") +
     labs(title = "Distribution of Tumor Grades", 
          x = "Grade", y = "Count") +
     theme_minimal()
   ```

3. **Create a box plot of Age by Gender:**
   ```r
   ggplot(data, aes(x = Gender, y = Age, fill = Gender)) +
     geom_boxplot() +
     labs(title = "Age Distribution by Gender", 
          x = "Gender", y = "Age (years)") +
     theme_minimal()
   ```

4. **Create a stacked bar plot:**
   ```r
   ggplot(data, aes(x = Grade, fill = Gender)) +
     geom_bar(position = "stack") +
     labs(title = "Tumor Grade by Gender", 
          x = "Grade", y = "Count") +
     theme_minimal()
   ```

**Questions to answer:**
- What is the age distribution pattern?
- Are there differences in age between males and females?
- How do tumor grades vary by gender?

### Task 4: Data Manipulation (10 minutes)

1. **Create a new variable for age groups:**
   ```r
   data$Age_Group <- cut(data$Age, 
                        breaks = c(0, 40, 60, 100), 
                        labels = c("Young", "Middle", "Elderly"))
   ```

2. **Filter data for specific conditions:**
   ```r
   # Patients with Grade IV tumors
   grade_iv <- data %>% filter(Grade == "IV")
   
   # Female patients only
   females <- data %>% filter(Gender == "Female")
   ```

3. **Group and summarize data:**
   ```r
   # Average age by grade
   data %>% 
     group_by(Grade) %>% 
     summarise(mean_age = mean(Age, na.rm = TRUE),
               n_patients = n())
   ```

**Questions to answer:**
- How many patients have Grade IV tumors?
- What is the average age for each tumor grade?
- How does the age distribution differ between age groups?

### Task 5: Customization Challenge (5 minutes)

**Challenge:** Create a publication-ready plot of your choice using the skills learned. Consider:
- Appropriate color schemes
- Clear titles and labels
- Professional appearance
- Meaningful insights

**Example:**
```r
ggplot(data, aes(x = Grade, fill = IDH_mutation_status)) +
  geom_bar(position = "dodge") +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Tumor Grade Distribution by IDH Mutation Status",
       subtitle = "Clinical Data Analysis",
       x = "Tumor Grade", 
       y = "Number of Patients",
       fill = "IDH Status") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        axis.text = element_text(size = 12),
        legend.position = "bottom")
```

---

## 📝 Reflection Questions

After completing the exercise, reflect on:

1. **What was the most challenging part?**
   - ________________________________
   - ________________________________

2. **What insights did you discover about the data?**
   - ________________________________
   - ________________________________

3. **What would you like to explore further?**
   - ________________________________
   - ________________________________

4. **How confident do you feel with these skills? (1-10)**
   - Data import: ___ / 10
   - Basic statistics: ___ / 10
   - Visualization: ___ / 10
   - Data manipulation: ___ / 10

---

## 🎯 Extension Activities

If you finish early or want extra practice:

1. **Explore other variables** in the dataset
2. **Create different plot types** (scatter plots, density plots)
3. **Practice with different color schemes** and themes
4. **Try combining multiple variables** in single plots
5. **Experiment with plot customization** options

---

## ✅ Self-Assessment Checklist

- [ ] Successfully imported the dataset
- [ ] Explored data structure and missing values
- [ ] Calculated descriptive statistics
- [ ] Created at least 4 different plot types
- [ ] Performed basic data manipulation
- [ ] Customized at least one plot
- [ ] Answered reflection questions
- [ ] Completed extension activities (optional)

---

## 🆘 Need Help?

If you get stuck:
1. Review the relevant sections in Lesson 1
2. Check the [Troubleshooting Guide](../docs/troubleshooting.md)
3. Use R's built-in help: `?function_name`
4. Search online for R documentation

---

## 🎉 Congratulations!

You've completed Exercise 1! You now have solid foundations in:
- Data import and exploration
- Basic statistical summaries
- Multiple visualization techniques
- Data manipulation skills

**Next Steps:** Move on to Lesson 2 to learn about more advanced descriptive statistics and distributions!

---

*Keep practicing and exploring - every analysis teaches you something new! 🧬📊* 