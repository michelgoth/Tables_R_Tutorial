# NOTE: This Shiny app is optional and archived from the learning flow.
# The primary focus of this repository is the code-first lessons in R/.
# You can still run this app by moving it back to the root or sourcing it from extras/.

# Load required libraries
library(shiny)
library(shinydashboard)
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(DT)
library(plotly)
library(corrplot)
library(survival)
library(survminer)

# UI Definition
ui <- dashboardPage(
  dashboardHeader(
    title = "Clinical Data Analysis Learning Platform",
    titleWidth = 400
  ),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Explorer", tabName = "data_explorer", icon = icon("table")),
      menuItem("Survival Analysis", tabName = "survival", icon = icon("heartbeat")),
      menuItem("Statistical Tests", tabName = "statistical", icon = icon("chart-bar")),
      menuItem("Machine Learning", tabName = "machine_learning", icon = icon("brain")),
      menuItem("Visualizations", tabName = "visualizations", icon = icon("chart-line")),
      menuItem("Progress Tracker", tabName = "progress", icon = icon("tasks")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          box(
            title = "Welcome to Clinical Data Analysis",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            p("This interactive platform provides hands-on experience with clinical data analysis using R. 
              Explore real clinical data, perform statistical analyses, and learn advanced techniques."),
            p("Navigate through the tabs to explore different aspects of clinical data analysis.")
          )
        ),
        fluidRow(
          valueBox(
            value = "325",
            subtitle = "Patients",
            icon = icon("users"),
            color = "blue"
          ),
          valueBox(
            value = "15",
            subtitle = "Lessons Available",
            icon = icon("book"),
            color = "green"
          ),
          valueBox(
            value = "10+",
            subtitle = "Statistical Methods",
            icon = icon("chart-bar"),
            color = "purple"
          )
        ),
        fluidRow(
          box(
            title = "Quick Start Guide",
            status = "info",
            width = 6,
            tags$ol(
              tags$li("Start with Data Explorer to understand your dataset"),
              tags$li("Use Survival Analysis for time-to-event data"),
              tags$li("Perform Statistical Tests for group comparisons"),
              tags$li("Try Machine Learning for prediction models"),
              tags$li("Create Visualizations for publication-ready figures")
            )
          ),
          box(
            title = "Learning Objectives",
            status = "success",
            width = 6,
            tags$ul(
              tags$li("Understand clinical data structure"),
              tags$li("Perform survival analysis"),
              tags$li("Apply statistical tests appropriately"),
              tags$li("Build prediction models"),
              tags$li("Create professional visualizations")
            )
          )
        )
      ),
      
      # Data Explorer Tab
      tabItem(tabName = "data_explorer",
        fluidRow(
          box(
            title = "Data Overview",
            status = "primary",
            width = 12,
            verbatimTextOutput("data_summary")
          )
        ),
        fluidRow(
          box(
            title = "Data Table",
            width = 12,
            DTOutput("data_table")
          )
        ),
        fluidRow(
          box(
            title = "Variable Distribution",
            width = 6,
            selectInput("var_select", "Select Variable:", choices = NULL),
            plotOutput("var_plot")
          ),
          box(
            title = "Missing Data",
            width = 6,
            plotOutput("missing_plot")
          )
        )
      ),
      
      # Survival Analysis Tab
      tabItem(tabName = "survival",
        fluidRow(
          box(
            title = "Survival Analysis Controls",
            status = "primary",
            width = 4,
            selectInput("surv_group", "Group by:", choices = NULL),
            selectInput("surv_method", "Method:", 
                       choices = c("Kaplan-Meier", "Cox Regression")),
            actionButton("run_survival", "Run Analysis", class = "btn-primary")
          ),
          box(
            title = "Survival Plot",
            width = 8,
            plotOutput("survival_plot")
          )
        ),
        fluidRow(
          box(
            title = "Survival Summary",
            width = 12,
            verbatimTextOutput("survival_summary")
          )
        )
      ),
      
      # Statistical Tests Tab
      tabItem(tabName = "statistical",
        fluidRow(
          box(
            title = "Statistical Test Controls",
            status = "primary",
            width = 4,
            selectInput("test_type", "Test Type:", 
                       choices = c("t-test", "Wilcoxon", "Chi-square", "ANOVA")),
            selectInput("test_var1", "Variable 1:", choices = NULL),
            selectInput("test_var2", "Variable 2:", choices = NULL),
            actionButton("run_test", "Run Test", class = "btn-primary")
          ),
          box(
            title = "Test Results",
            width = 8,
            verbatimTextOutput("test_results")
          )
        ),
        fluidRow(
          box(
            title = "Test Visualization",
            width = 12,
            plotOutput("test_plot")
          )
        )
      ),
      
      # Machine Learning Tab
      tabItem(tabName = "machine_learning",
        fluidRow(
          box(
            title = "Machine Learning Controls",
            status = "primary",
            width = 4,
            selectInput("ml_method", "Method:", 
                       choices = c("Random Forest", "Logistic Regression", "Cox Regression")),
            selectInput("ml_outcome", "Outcome Variable:", choices = NULL),
            selectInput("ml_predictors", "Predictors:", choices = NULL, multiple = TRUE),
            actionButton("run_ml", "Run Model", class = "btn-primary")
          ),
          box(
            title = "Model Results",
            width = 8,
            verbatimTextOutput("ml_results")
          )
        ),
        fluidRow(
          box(
            title = "Model Performance",
            width = 6,
            plotOutput("ml_performance")
          ),
          box(
            title = "Feature Importance",
            width = 6,
            plotOutput("ml_importance")
          )
        )
      ),
      
      # Visualizations Tab
      tabItem(tabName = "visualizations",
        fluidRow(
          box(
            title = "Visualization Controls",
            status = "primary",
            width = 3,
            selectInput("plot_type", "Plot Type:", 
                       choices = c("Histogram", "Boxplot", "Scatter", "Correlation", "Survival")),
            selectInput("plot_x", "X Variable:", choices = NULL),
            selectInput("plot_y", "Y Variable:", choices = NULL),
            selectInput("plot_color", "Color by:", choices = NULL),
            actionButton("create_plot", "Create Plot", class = "btn-primary")
          ),
          box(
            title = "Plot",
            width = 9,
            plotOutput("main_plot")
          )
        ),
        fluidRow(
          box(
            title = "Plot Code",
            width = 12,
            verbatimTextOutput("plot_code")
          )
        )
      ),
      
      # Progress Tracker Tab
      tabItem(tabName = "progress",
        fluidRow(
          box(
            title = "Learning Progress",
            status = "primary",
            width = 12,
            progressBar(id = "overall_progress", value = 0, display_pct = TRUE)
          )
        ),
        fluidRow(
          box(
            title = "Completed Lessons",
            width = 6,
            checkboxGroupInput("completed_lessons", "Mark as completed:",
                              choices = paste("Lesson", 1:15))
          ),
          box(
            title = "Skills Assessment",
            width = 6,
            selectInput("skill_level", "Current Skill Level:",
                       choices = c("Beginner", "Intermediate", "Advanced")),
            textAreaInput("notes", "Learning Notes:", rows = 5)
          )
        )
      ),
      
      # About Tab
      tabItem(tabName = "about",
        fluidRow(
          box(
            title = "About This Platform",
            status = "primary",
            width = 12,
            h3("Clinical Data Analysis Learning Platform"),
            p("This interactive platform is designed to provide hands-on experience with clinical data analysis using R."),
            h4("Features:"),
            tags$ul(
              tags$li("Real clinical data from 325 patients"),
              tags$li("Interactive statistical analyses"),
              tags$li("Machine learning models"),
              tags$li("Publication-ready visualizations"),
              tags$li("Progress tracking"),
              tags$li("Comprehensive documentation")
            ),
            h4("Learning Path:"),
            tags$ol(
              tags$li("Data exploration and understanding"),
              tags$li("Descriptive statistics and visualization"),
              tags$li("Survival analysis and time-to-event data"),
              tags$li("Statistical testing and inference"),
              tags$li("Machine learning and prediction"),
              tags$li("Advanced techniques and interpretation")
            )
          )
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Load data
  data <- reactive({
    tryCatch({
      read_excel("Data/ClinicalData.xlsx")
    }, error = function(e) {
      # Create sample data if file not found
      set.seed(123)
      data.frame(
        Patient_ID = 1:325,
        Age = rnorm(325, 60, 15),
        Gender = sample(c("Male", "Female"), 325, replace = TRUE),
        Grade = sample(c("WHO II", "WHO III", "WHO IV"), 325, replace = TRUE),
        OS = rweibull(325, shape = 1.5, scale = 24),
        Status = sample(c(0, 1), 325, replace = TRUE, prob = c(0.7, 0.3)),
        IDH_Status = sample(c("Mutant", "Wildtype"), 325, replace = TRUE),
        MGMT_Status = sample(c("Methylated", "Unmethylated"), 325, replace = TRUE)
      )
    })
  })
  
  # Update variable choices
  observe({
    df <- data()
    numeric_vars <- names(df)[sapply(df, is.numeric)]
    categorical_vars <- names(df)[sapply(df, is.character) | sapply(df, is.factor)]
    
    updateSelectInput(session, "var_select", choices = names(df))
    updateSelectInput(session, "surv_group", choices = categorical_vars)
    updateSelectInput(session, "test_var1", choices = names(df))
    updateSelectInput(session, "test_var2", choices = names(df))
    updateSelectInput(session, "ml_outcome", choices = names(df))
    updateSelectInput(session, "ml_predictors", choices = names(df))
    updateSelectInput(session, "plot_x", choices = names(df))
    updateSelectInput(session, "plot_y", choices = names(df))
    updateSelectInput(session, "plot_color", choices = c("None", categorical_vars))
  })
  
  # Data Explorer Outputs
  output$data_summary <- renderPrint({
    df <- data()
    cat("Dataset Summary:\n")
    cat("Dimensions:", nrow(df), "x", ncol(df), "\n")
    cat("Variables:", paste(names(df), collapse = ", "), "\n\n")
    str(df)
  })
  
  output$data_table <- renderDT({
    datatable(data(), 
              options = list(pageLength = 10, scrollX = TRUE),
              filter = "top")
  })
  
  output$var_plot <- renderPlot({
    req(input$var_select)
    df <- data()
    var <- input$var_select
    
    if (is.numeric(df[[var]])) {
      ggplot(df, aes_string(x = var)) +
        geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
        theme_minimal() +
        labs(title = paste("Distribution of", var))
    } else {
      ggplot(df, aes_string(x = var)) +
        geom_bar(fill = "steelblue", alpha = 0.7) +
        theme_minimal() +
        labs(title = paste("Distribution of", var)) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  })
  
  output$missing_plot <- renderPlot({
    df <- data()
    missing_data <- data.frame(
      Variable = names(df),
      Missing = sapply(df, function(x) sum(is.na(x)))
    )
    
    ggplot(missing_data, aes(x = reorder(Variable, Missing), y = Missing)) +
      geom_bar(stat = "identity", fill = "red", alpha = 0.7) +
      coord_flip() +
      theme_minimal() +
      labs(title = "Missing Data by Variable", x = "Variable", y = "Count")
  })
  
  # Survival Analysis Outputs
  observeEvent(input$run_survival, {
    req(input$surv_group)
    df <- data()
    
    if (input$surv_method == "Kaplan-Meier") {
      # Create survival object
      surv_obj <- Surv(df$OS, df$Status)
      
      # Fit survival model
      fit <- survfit(surv_obj ~ df[[input$surv_group]])
      
      # Create plot
      output$survival_plot <- renderPlot({
        ggsurvplot(fit, data = df, 
                   pval = TRUE, conf.int = TRUE,
                   risk.table = TRUE, palette = "Set1",
                   title = paste("Survival Analysis by", input$surv_group))
      })
      
      # Summary
      output$survival_summary <- renderPrint({
        cat("Kaplan-Meier Survival Analysis\n")
        cat("Group variable:", input$surv_group, "\n\n")
        print(summary(fit))
        cat("\nLog-rank test:\n")
        print(survdiff(surv_obj ~ df[[input$surv_group]]))
      })
    }
  })
  
  # Statistical Tests Outputs
  observeEvent(input$run_test, {
    req(input$test_var1, input$test_var2)
    df <- data()
    var1 <- df[[input$test_var1]]
    var2 <- df[[input$test_var2]]
    
    output$test_results <- renderPrint({
      cat("Statistical Test Results\n")
      cat("Test:", input$test_type, "\n")
      cat("Variable 1:", input$test_var1, "\n")
      cat("Variable 2:", input$test_var2, "\n\n")
      
      if (input$test_type == "t-test" && is.numeric(var1) && is.numeric(var2)) {
        print(t.test(var1, var2))
      } else if (input$test_type == "Wilcoxon" && is.numeric(var1) && is.numeric(var2)) {
        print(wilcox.test(var1, var2))
      } else if (input$test_type == "Chi-square") {
        print(chisq.test(table(var1, var2)))
      } else if (input$test_type == "ANOVA" && is.numeric(var1)) {
        print(aov(var1 ~ var2))
      } else {
        cat("Incompatible variable types for selected test.\n")
      }
    })
    
    # Create test plot
    output$test_plot <- renderPlot({
      if (input$test_type %in% c("t-test", "Wilcoxon") && is.numeric(var1) && is.numeric(var2)) {
        plot_data <- data.frame(
          Group = rep(c(input$test_var1, input$test_var2), 
                     c(length(var1), length(var2))),
          Value = c(var1, var2)
        )
        ggplot(plot_data, aes(x = Group, y = Value)) +
          geom_boxplot(fill = "steelblue", alpha = 0.7) +
          theme_minimal() +
          labs(title = paste(input$test_type, "Comparison"))
      } else if (input$test_type == "Chi-square") {
        mosaicplot(table(var1, var2), main = "Chi-square Test")
      }
    })
  })
  
  # Machine Learning Outputs
  observeEvent(input$run_ml, {
    req(input$ml_outcome, input$ml_predictors)
    df <- data()
    
    output$ml_results <- renderPrint({
      cat("Machine Learning Model Results\n")
      cat("Method:", input$ml_method, "\n")
      cat("Outcome:", input$ml_outcome, "\n")
      cat("Predictors:", paste(input$ml_predictors, collapse = ", "), "\n\n")
      
      # Simple model for demonstration
      if (input$ml_method == "Logistic Regression") {
        formula_str <- paste(input$ml_outcome, "~", paste(input$ml_predictors, collapse = " + "))
        model <- glm(as.formula(formula_str), data = df, family = "binomial")
        print(summary(model))
      }
    })
  })
  
  # Visualization Outputs
  observeEvent(input$create_plot, {
    req(input$plot_type, input$plot_x)
    df <- data()
    
    output$main_plot <- renderPlot({
      if (input$plot_type == "Histogram") {
        ggplot(df, aes_string(x = input$plot_x)) +
          geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
          theme_minimal() +
          labs(title = paste("Histogram of", input$plot_x))
      } else if (input$plot_type == "Boxplot" && input$plot_color != "None") {
        ggplot(df, aes_string(x = input$plot_color, y = input$plot_x)) +
          geom_boxplot(fill = "steelblue", alpha = 0.7) +
          theme_minimal() +
          labs(title = paste("Boxplot of", input$plot_x, "by", input$plot_color))
      } else if (input$plot_type == "Scatter" && input$plot_y != "") {
        ggplot(df, aes_string(x = input$plot_x, y = input$plot_y)) +
          geom_point(alpha = 0.6) +
          geom_smooth(method = "lm") +
          theme_minimal() +
          labs(title = paste("Scatter plot:", input$plot_x, "vs", input$plot_y))
      }
    })
    
    # Generate plot code
    output$plot_code <- renderPrint({
      cat("# R code to recreate this plot:\n")
      if (input$plot_type == "Histogram") {
        cat("ggplot(data, aes(x =", input$plot_x, ")) +\n")
        cat("  geom_histogram(bins = 30, fill = 'steelblue', alpha = 0.7) +\n")
        cat("  theme_minimal() +\n")
        cat("  labs(title = 'Histogram of", input$plot_x, "')\n")
      }
    })
  })
  
  # Progress Tracker
  observe({
    completed <- length(input$completed_lessons)
    total <- 15
    progress <- (completed / total) * 100
    
    updateProgressBar(session, "overall_progress", value = progress)
  })
}

# Run the application
shinyApp(ui = ui, server = server) 