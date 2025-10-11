# =========================================================
# PROJECT: WhatsApp Chat Sentiment Analysis (v4 - Text Summary)
# AUTHOR: Teja Poosa
# FEATURES: Faster processing, progress bar, clearer UI, textual summary panel
# =========================================================

# ---- Step 1: Load Libraries ----
library(shiny)
library(bslib)
library(syuzhet)
library(ggplot2)
library(tidytext) 
library(wordcloud)
library(RColorBrewer)
library(lubridate)
library(dplyr)
library(pheatmap)
library(stringr)


# ---- Step 2: Define the Enhanced User Interface (UI) ----
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "cerulean"),
  
  titlePanel("Optimized WhatsApp Chat Sentiment Analyzer"),
  
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        h4("Controls"),
        fileInput("chatFile", "1. Upload Chat .txt File",
                  accept = c("text/plain", ".txt")),
        
        actionButton("analyzeBtn", "Analyze Chat!", icon = icon("rocket"), class = "btn-primary btn-lg", width = "100%")
      ),
      
      wellPanel(
        # This UI element is generated dynamically after analysis
        uiOutput("user_selector_ui"),
        hr(),
        h5("Analysis Information"),
        textOutput("analysis_timestamp")
      )
    ),
    
    mainPanel(
      tabsetPanel(type = "tabs",
                  id = "main_tabs",
                  
                  ## --- NEW: Textual Summary Tab Panel ---
                  tabPanel("Chat Summary", 
                           icon = icon("info-circle"),
                           fluidRow(
                             column(6, wellPanel(
                               h4("Overall Statistics"),
                               verbatimTextOutput("total_messages"),
                               verbatimTextOutput("total_users"),
                               verbatimTextOutput("media_omitted")
                             )),
                             column(6, wellPanel(
                               h4("Time Span"),
                               verbatimTextOutput("chat_period")
                             ))
                           ),
                           fluidRow(
                             column(6, wellPanel(
                               h4("Key Activity Metrics"),
                               verbatimTextOutput("active_user"),
                               verbatimTextOutput("busiest_day")
                             )),
                             column(6, wellPanel(
                               h4("Sentiment Overview"),
                               verbatimTextOutput("sentiment_summary")
                             ))
                           )
                  ),
                  
                  tabPanel("Overall Sentiment", 
                           plotOutput("sentimentBarChart", height = "400px"),
                           hr(),
                           plotOutput("sentimentComparison", height = "400px")
                  ),
                  tabPanel("User Activity", 
                           plotOutput("topUsersChart", height = "400px"),
                           hr(),
                           plotOutput("dailyActivityChart", height = "400px")
                  ),
                  tabPanel("Content Analysis", 
                           plotOutput("wordCloud", height = "400px"),
                           hr(),
                           plotOutput("activityHeatmap", height = "400px")
                  ),
                  tabPanel("Sentiment Trends",
                           plotOutput("dailySentimentTrend", height = "500px")
                  )
      )
    )
  )
)


# ---- Step 3: Define the Optimized Server Logic ----
server <- function(input, output, session) {
  
  # A reactive value to hold all our processed data
  analysis_results <- eventReactive(input$analyzeBtn, {
    req(input$chatFile)
    
    # --- NEW: Progress bar to give user feedback ---
    withProgress(message = 'Analysis in Progress', value = 0, {
      
      # --- Task 1: Parsing and Cleaning ---
      incProgress(1/5, detail = "Parsing chat file...")
      
      texts_raw <- readLines(input$chatFile$datapath, encoding = "UTF-8")
      
      ## --- NEW: Count media messages before cleaning them out ---
      media_count <- sum(grepl("image omitted|video omitted|audio omitted|sticker omitted|<Media omitted>", texts_raw, ignore.case = TRUE))
      
      pattern <- "^(\\d{1,2}/\\d{1,2}/\\d{2,4}), (\\d{1,2}:\\d{2}\\s[ap]m) - (.*?): (.*)$"
      matches <- str_match(texts_raw, pattern)
      
      chat_df <- data.frame(
        date_str = matches[,2], time_str = matches[,3],
        name = matches[,4], text = matches[,5],
        stringsAsFactors = FALSE
      )
      
      chat_df_clean <- chat_df %>%
        filter(!is.na(name) & !is.na(text)) %>%
        mutate(datetime = parse_date_time(paste(date_str, time_str), orders = c("dmy HM p", "mdy HM p"), quiet = TRUE)) %>%
        filter(!is.na(datetime)) %>%
        filter(!grepl("image omitted|video omitted|audio omitted|sticker omitted|<Media omitted>|This message was deleted", text, ignore.case = TRUE))
      
      if (nrow(chat_df_clean) == 0) {
        showNotification("No valid messages found to analyze.", type = "warning")
        return(NULL)
      }
      
      # --- Task 2: Sentiment Analysis (Can be slow) ---
      incProgress(2/5, detail = "Analyzing sentiment...")
      sentiment <- get_nrc_sentiment(chat_df_clean$text)
      chat_with_sentiment <- cbind(chat_df_clean, sentiment)
      
      # --- Task 3: Word Frequency (FASTER METHOD) ---
      incProgress(3/5, detail = "Calculating word frequencies...")
      word_freqs <- chat_df_clean %>%
        unnest_tokens(word, text) %>%
        anti_join(stop_words, by = "word") %>%
        count(word, sort = TRUE)
      
      # --- Task 4: Calculate Summary Statistics ---
      incProgress(4/5, detail = "Calculating summary stats...")
      
      ## --- NEW: Calculations for the summary tab ---
      total_messages <- nrow(chat_df_clean)
      total_users <- length(unique(chat_df_clean$name))
      chat_start_date <- as.Date(min(chat_df_clean$datetime))
      chat_end_date <- as.Date(max(chat_df_clean$datetime))
      chat_period <- paste(format(chat_start_date, "%d %b, %Y"), "to", format(chat_end_date, "%d %b, %Y"))
      
      most_active <- chat_df_clean %>% count(name, sort = TRUE) %>% top_n(1)
      active_user_text <- paste(most_active$name[1], " (", most_active$n[1], " messages)", sep="")
      
      busiest <- chat_df_clean %>% group_by(Date = as.Date(datetime)) %>% summarise(count = n()) %>% top_n(1)
      busiest_day_text <- paste(format(busiest$Date[1], "%A, %d %b %Y"), " (", busiest$count[1], " messages)", sep="")
      
      pos_count <- sum(sentiment$positive)
      neg_count <- sum(sentiment$negative)
      sentiment_total <- pos_count + neg_count
      pos_percent <- if(sentiment_total > 0) round((pos_count / sentiment_total) * 100, 1) else 0
      sentiment_text <- paste(pos_percent, "% Positive vs ", 100 - pos_percent, "% Negative", sep="")
      
      # --- Task 5: Finalizing ---
      incProgress(5/5, detail = "Done!")
      
      showNotification("Analysis Complete!", type = "message")
      
      # Return a list containing all our results
      list(
        chat_data = chat_with_sentiment,
        word_freqs = word_freqs,
        ## --- NEW: Add summary stats to the results list ---
        summary_stats = list(
          total_messages = total_messages,
          total_users = total_users,
          media_omitted = media_count,
          chat_period = chat_period,
          active_user = active_user_text,
          busiest_day = busiest_day_text,
          sentiment_summary = sentiment_text
        )
      )
    })
  })
  
  # Dynamically create the user selection dropdown
  output$user_selector_ui <- renderUI({
    results <- analysis_results()
    if (!is.null(results)) {
      user_list <- unique(results$chat_data$name)
      selectInput("selected_users", "2. Filter Results by User(s)",
                  choices = c("All Users", user_list),
                  selected = "All Users",
                  multiple = TRUE)
    }
  })
  
  # Create filtered data based on user selection
  filtered_data <- reactive({
    results <- analysis_results()
    req(results)
    
    if (is.null(input$selected_users) || "All Users" %in% input$selected_users) {
      return(results$chat_data)
    } else {
      return(results$chat_data %>% filter(name %in% input$selected_users))
    }
  })
  
  # Render analysis timestamp
  output$analysis_timestamp <- renderText({
    req(analysis_results())
    paste("Analysis performed at:", format(Sys.time(), "%H:%M:%S on %Y-%m-%d"))
  })
  
  ## --- NEW: Render functions for the Text Summary tab ---
  output$total_messages <- renderText({
    req(analysis_results())
    paste("Total Messages Analyzed:", analysis_results()$summary_stats$total_messages)
  })
  
  output$total_users <- renderText({
    req(analysis_results())
    paste("Unique Participants:", analysis_results()$summary_stats$total_users)
  })
  
  output$media_omitted <- renderText({
    req(analysis_results())
    paste("Media Messages Omitted:", analysis_results()$summary_stats$media_omitted)
  })
  
  output$chat_period <- renderText({
    req(analysis_results())
    paste("Conversation Period:", analysis_results()$summary_stats$chat_period)
  })
  
  output$active_user <- renderText({
    req(analysis_results())
    paste("Most Active User:", analysis_results()$summary_stats$active_user)
  })
  
  output$busiest_day <- renderText({
    req(analysis_results())
    paste("Busiest Day:", analysis_results()$summary_stats$busiest_day)
  })
  
  output$sentiment_summary <- renderText({
    req(analysis_results())
    paste("Overall Tone:", analysis_results()$summary_stats$sentiment_summary)
  })
  
  
  # ---- Render Plots using the filtered data ----
  
  output$sentimentBarChart <- renderPlot({
    df <- filtered_data()
    req(df)
    TotalSentiment <- data.frame(count = colSums(df[, (ncol(df)-9):ncol(df)]))
    TotalSentiment <- cbind(sentiment = rownames(TotalSentiment), TotalSentiment)
    ggplot(TotalSentiment, aes(x = reorder(sentiment, -count), y = count, fill = sentiment)) +
      geom_bar(stat = "identity") + theme_minimal(base_size = 14) +
      labs(title = "Overall Sentiment Breakdown", x = "Sentiment", y = "Frequency") + theme(legend.position = "none")
  })
  
  output$sentimentComparison <- renderPlot({
    df <- filtered_data()
    req(df)
    barplot(colSums(df[, c("positive", "negative")]),
            col = c("#4CAF50", "#F44336"), main = "Positive vs Negative", ylab = "Frequency")
  })
  
  output$wordCloud <- renderPlot({
    word_freqs <- analysis_results()$word_freqs # Get pre-calculated frequencies
    req(word_freqs)
    
    if (is.null(input$selected_users) || "All Users" %in% input$selected_users) {
      display_words <- word_freqs
    } else {
      display_words <- filtered_data() %>%
        unnest_tokens(word, text) %>%
        anti_join(stop_words, by = "word") %>%
        count(word, sort = TRUE)
    }
    
    wordcloud(words = display_words$word, freq = display_words$n, min.freq = 5, max.words = 150,
              random.order = FALSE, colors = brewer.pal(8, "Dark2"))
  })
  
  output$topUsersChart <- renderPlot({
    df <- analysis_results()$chat_data # Use the full dataset for this chart
    req(df)
    user_activity <- df %>% count(name, sort = TRUE) %>% rename(User = name, Messages = n)
    ggplot(head(user_activity, 15), aes(x = reorder(User, Messages), y = Messages, fill = User)) +
      geom_bar(stat = "identity") + coord_flip() + theme_minimal(base_size = 14) +
      labs(title = "Top 15 Active Users (Overall)", x = "", y = "Total Messages") + theme(legend.position = "none")
  })
  
  output$dailyActivityChart <- renderPlot({
    df <- filtered_data()
    req(df)
    daily_msgs <- df %>% group_by(Date = as.Date(datetime)) %>% summarise(Messages = n(), .groups = "drop")
    ggplot(daily_msgs, aes(x = Date, y = Messages)) +
      geom_line(color = "steelblue", size = 1) + theme_minimal(base_size = 14) +
      labs(title = "Daily Message Activity", x = "Date", y = "Messages")
  })
  
  output$activityHeatmap <- renderPlot({
    df <- filtered_data()
    req(df)
    activity_matrix <- table(Weekday = weekdays(df$datetime), Hour = hour(df$datetime))
    ordered_days <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
    activity_matrix <- activity_matrix[match(ordered_days, rownames(activity_matrix)),, drop = FALSE]
    
    pheatmap(activity_matrix, cluster_rows = FALSE, cluster_cols = FALSE,
             color = colorRampPalette(c("#E3F2FD", "#2196F3"))(50),
             main = "Activity Heatmap", fontsize = 12)
  })
  
  output$dailySentimentTrend <- renderPlot({
    df <- filtered_data()
    req(df)
    sentiment_daily <- df %>%
      group_by(Date = as.Date(datetime)) %>%
      summarise(positive = sum(positive), negative = sum(negative), .groups = "drop")
    
    ggplot(sentiment_daily, aes(x = Date)) +
      geom_line(aes(y = positive, color = "Positive"), size = 1) +
      geom_line(aes(y = negative, color = "Negative"), size = 1) +
      theme_minimal(base_size = 14) +
      labs(title = "Daily Sentiment Trend", x = "Date", y = "Count", color = "Sentiment") +
      scale_color_manual(values = c("Positive" = "#4CAF50", "Negative" = "#F44336"))
  })
  
}

# ---- Step 4: Run the application ----
shinyApp(ui = ui, server = server)
