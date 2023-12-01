# Shiny app for RYB Chapter 1 Exercise 1-2 from my book 'Reimagining Your Business, A Personalized Guidebook to Beat Your Competition'

# Deployed to shinyapps.io Nov 13, 2023

# PUSH to GitHub any time the app is updated
# REPUBLISH via RStudio any time the app is updated


library(shiny)
library(rmarkdown)

ui <- fluidPage(
    titlePanel("Chapter 1 – Exercise 1-2"),
    
    # Save to PDF Button (Top)
    fluidRow(
        column(12, downloadButton("downloadPDF_top", "Save to PDF", class = "btn-danger"))
    ),
    
    # Specific Questions and Input Fields with Reset Buttons
    fluidRow(
        column(12, h3("Ideas take form when you commit them to writing. Write your answers to the following questions:"))
    ),
    lapply(1:5, function(i) {
        questionText <- c(
            "1. Are there gaps in the market that you can fill with innovative products or services, or is it already saturated with similar offerings?",
            "2. What has your market research revealed to you so far?",
            "3. How quickly do you need to bring your product or service to market?",
            "4. How would you 'bounce back' if the company failed and people lost money?",
            "5. Describe any industry-specific knowledge or technical skills that your competition will find difficult to duplicate."
        )
        fluidRow(
            column(12,
                   h4(questionText[i]),
                   textAreaInput(paste("input", i, sep = ""), label = NULL, placeholder = "Type your answer here..."),
                   actionButton(paste("reset", i, sep = ""), "Reset")
            )
        )
    }),
    
    # Reset All Button
    fluidRow(
        column(12, actionButton("reset_all", "Reset All"))
    ),
    
    # Save to PDF Button (Bottom)
    fluidRow(
        column(12, downloadButton("downloadPDF", "Save to PDF", class = "btn-danger"))
    ),
    
    # Warning Message
    tags$script(HTML("
        $(window).on('beforeunload', function(){
            return 'Are you sure you want to leave? All your data will be lost.';
        });
    "))
)

server <- function(input, output, session) {
    # Reset Individual Fields
    lapply(1:5, function(i) {
        observeEvent(input[[paste("reset", i, sep = "")]], {
            updateTextAreaInput(session, paste("input", i, sep = ""), value = "")
        })
    })
    
    # Reset All Fields
    observeEvent(input$reset_all, {
        lapply(1:5, function(i) {
            updateTextAreaInput(session, paste("input", i, sep = ""), value = "")
        })
    })
    
    # Function for PDF Generation
    generatePDF <- function(file) {
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.create(tempReport)
        dateTime <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        answers <- sapply(1:5, function(i) input[[paste("input", i, sep = "")]], USE.NAMES = FALSE)
        writeLines(c(
            "---",
            "title: 'Chapter 1 – Exercise 1-2 Answers'",
            "author: 'Generated on", dateTime, "'",
            "output: pdf_document",
            "geometry: margin=1in",
            "---",
            "",
            paste("1. **", answers[1], "**"),
            "",
            paste("2. **", answers[2], "**"),
            "",
            paste("3. **", answers[3], "**"),
            "",
            paste("4. **", answers[4], "**"),
            "",
            paste("5. **", answers[5], "**")
        ), tempReport)
        rmarkdown::render(tempReport, output_file = file)
    }
    
    # Save to PDF (Top and Bottom Buttons)
    output$downloadPDF_top <- downloadHandler(
        filename = function() { paste("exercise-1-2-", Sys.Date(), ".pdf", sep = "") },
        content = generatePDF,
        contentType = "application/pdf"
    )
    output$downloadPDF <- downloadHandler(
        filename = function() { paste("exercise-1-2-", Sys.Date(), ".pdf", sep = "") },
        content = generatePDF,
        contentType = "application/pdf"
    )
}

# Run the application
shinyApp(ui = ui, server = server)
