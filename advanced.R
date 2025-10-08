# ============================================
# PROJECT: WhatsApp Chat Sentiment Analysis
# SUBJECT: Big Data Analytics (BDA)
# AUTHOR: Teja Poosa
# ============================================

# ---- Step 1: Setup ----
# Sets the working directory. Make sure to change this path to your project folder.
setwd("C:/Users/teja/Desktop/BDA Project")
print(getwd())

# ---- Step 2: Load Libraries ----
library(syuzhet)
library(ggplot2)
library(tm)
library(wordcloud)
library(RColorBrewer)
library(lubridate)
library(dplyr)
library(pheatmap)
library(stringr)

# ---- Step 3: Import Chat File ----
# Opens a file dialog for you to choose your exported WhatsApp .txt file.
texts_raw <- readLines(file.choose(), encoding = "UTF-8")
cat("✅ Raw chat file loaded successfully. Total lines:", length(texts_raw), "\n")


# ---- Step 4: Define the Correct Regex Pattern and Parse Text ----
# This pattern is specifically tailored to your file's format:
# dd/mm/yyyy, hh:mm am/pm - Author: Message
pattern <- "^(\\d{1,2}/\\d{1,2}/\\d{2,4}), (\\d{1,2}:\\d{2}\\s[ap]m) - (.*?): (.*)$"

# Apply the pattern to each line of the raw text.
matches <- str_match(texts_raw, pattern)

# Create a data frame from the captured groups.
chat_df <- data.frame(
  date_str = matches[,2],
  time_str = matches[,3],
  name     = matches[,4],
  text     = matches[,5], # The message text is the 4th captured group
  stringsAsFactors = FALSE
)


# ---- Step 5: Clean the Data and Parse Dates ----
chat_df_clean <- chat_df %>%
  # Remove rows that are not messages (where the pattern did not match).
  filter(!is.na(name) & !is.na(text)) %>%
  # Parse the date and time strings into a proper datetime object.
  # "dmy HM p" correctly handles the 12-hour am/pm format.
  mutate(datetime = parse_date_time(
    paste(date_str, time_str),
    orders = c("dmy HM p", "mdy HM p"), # Added 'p' for am/pm
    quiet = TRUE
  )) %>%
  # Remove any rows where date parsing might have failed and filter out non-message content.
  filter(!is.na(datetime)) %>%
  filter(!grepl("image omitted|video omitted|audio omitted|sticker omitted|<Media omitted>|This message was deleted", text, ignore.case = TRUE))

cat("✅ Data cleaned and parsed. Total messages processed:", nrow(chat_df_clean), "\n")


# ---- Step 6: Sentiment Analysis ----
# This block will now run correctly as long as messages were processed.
if (nrow(chat_df_clean) > 0) {
  sentiment <- get_nrc_sentiment(chat_df_clean$text)
  cat("✅ Sentiment analysis completed.\n")
  
  # ---- Step 7: Combine Sentiment Scores with the Main DataFrame ----
  chat_with_sentiment <- cbind(chat_df_clean, sentiment)
  
  # ---- Step 8 to 17: The rest of the analysis script ----
  
  # Summarize Sentiments
  TotalSentiment <- data.frame(count = colSums(chat_with_sentiment[, 6:15]))
  TotalSentiment <- cbind(sentiment = rownames(TotalSentiment), TotalSentiment)
  rownames(TotalSentiment) <- NULL
  print(TotalSentiment)
  
  # Bar Chart of Sentiments
  print(ggplot(TotalSentiment, aes(x = reorder(sentiment, -count), y = count, fill = sentiment)) +
          geom_bar(stat = "identity", width = 0.7) +
          geom_text(aes(label = count), vjust = -0.3, size = 4) +
          theme_minimal(base_size = 14) +
          labs(
            title = "WhatsApp Chat Sentiment Analysis",
            subtitle = "Based on NRC Lexicon (10 Sentiment Categories)",
            x = "Sentiment Type",
            y = "Frequency"
          ) +
          theme(legend.position = "none"))
  
  # Positive vs Negative Comparison
  barplot(
    colSums(chat_with_sentiment[, c("positive", "negative")]),
    beside = TRUE,
    col = c("darkgreen", "red"),
    names.arg = c("Positive", "Negative"),
    main = "Overall Sentiment Comparison",
    ylab = "Frequency"
  )
  
  # Word Cloud
  corpus <- VCorpus(VectorSource(chat_with_sentiment$text))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  tdm <- TermDocumentMatrix(corpus)
  m <- as.matrix(tdm)
  word_freq <- sort(rowSums(m), decreasing = TRUE)
  set.seed(123)
  wordcloud(names(word_freq), word_freq, min.freq = 5, max.words = 150,
            random.order = FALSE, colors = brewer.pal(8, "Dark2"))
  title("Word Cloud of WhatsApp Chat")
  
  # Daily Message Activity
  daily_msgs <- chat_with_sentiment %>%
    group_by(Date = as.Date(datetime)) %>%
    summarise(Messages = n(), .groups = "drop")
  
  print(ggplot(daily_msgs, aes(x = Date, y = Messages)) +
          geom_line(color = "blue") +
          geom_point(color = "darkblue") +
          theme_minimal() +
          labs(title = "Daily Message Activity", x = "Date", y = "Number of Messages"))
  
  # Activity Heatmap
  activity_matrix <- table(Weekday = weekdays(chat_with_sentiment$datetime), Hour = hour(chat_with_sentiment$datetime))
  pheatmap(activity_matrix, cluster_rows = FALSE, cluster_cols = FALSE,
           color = colorRampPalette(c("white", "red"))(50),
           main = "Message Activity Heatmap (Weekday vs Hour)")
  
  # Top Active Users
  user_activity <- chat_with_sentiment %>% count(name, sort = TRUE) %>% rename(User = name, Messages = n)
  print(ggplot(head(user_activity, 20), aes(x = reorder(User, Messages), y = Messages, fill = User)) +
          geom_bar(stat = "identity") +
          coord_flip() +
          theme_minimal() +
          labs(title = "Top 20 Active Users", x = "User", y = "Number of Messages") +
          theme(legend.position = "none"))
  
  # Daily Sentiment Trends
  sentiment_daily <- chat_with_sentiment %>%
    group_by(Date = as.Date(datetime)) %>%
    summarise(
      positive = sum(positive),
      negative = sum(negative),
      .groups = "drop"
    )
  
  print(ggplot(sentiment_daily, aes(x = Date)) +
          geom_line(aes(y = positive, color = "Positive")) +
          geom_line(aes(y = negative, color = "Negative")) +
          theme_minimal() +
          labs(title = "Daily Sentiment Trend", x = "Date", y = "Count", color = "Sentiment") +
          scale_color_manual(values = c("Positive" = "green", "Negative" = "red")))
  
  cat("✅✅✅ Full analysis script completed successfully! ✅✅✅\n")
  
} else {
  # This message will print if parsing still fails.
  cat("\n❌ ERROR: After cleaning, no messages were left to analyze. The script will stop.\n")
}