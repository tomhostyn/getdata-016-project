library (dplyr)
library(data.table)

run_analysis <- function (){
  #
  #  write final data table to wd
  #
    
  UCI_HAR_DT <- load_har_data_table()
  MEAN_UCI_HAR_DT <- transform_har_data_table(UCI_HAR_DT)
  write.table (MEAN_UCI_HAR_DT, paste (getwd(), sep="/", "mean_uci_har.txt"), row.name=FALSE)
}

load_har_data_table <- function(wd = getwd()){

  uci_har_dir <- "UCI HAR Dataset"
  uci_har_path <- paste (wd, sep="/", uci_har_dir)
  
  uci_har_train_path <- paste (uci_har_path, sep="/", "train")
  uci_har_test_path <- paste (uci_har_path, sep="/", "test")
  
  features_path <- paste (uci_har_path, sep="/", "features.txt")
  activities_path <- paste (uci_har_path, sep="/", "activity_labels.txt")
  
  subject_train_path <- paste(uci_har_train_path, sep="/", "subject_train.txt")
  X_train_path <- paste(uci_har_train_path, sep="/", "X_train.txt")
  Y_train_path <- paste(uci_har_train_path, sep="/", "Y_train.txt")
  
  subject_test_path <- paste(uci_har_test_path, sep="/", "subject_test.txt")
  X_test_path <- paste(uci_har_test_path, sep="/", "X_test.txt")
  Y_test_path <- paste(uci_har_test_path, sep="/", "Y_test.txt")
  
  delayedAssign("features", data.table(read.table(features_path, stringsAsFactors=FALSE)))
  delayedAssign("activities", data.table(read.table(activities_path, stringsAsFactors=TRUE)))
  
  delayedAssign("subject_train", data.table(read.table(subject_train_path)))
  delayedAssign("X_train", data.table(read.table (X_train_path)))
  delayedAssign("Y_train", data.table(read.table (Y_train_path)))
  
  delayedAssign("subject_test", data.table(read.table(subject_test_path)))
  delayedAssign("X_test", data.table(read.table (X_test_path)))
  delayedAssign("Y_test", data.table(read.table (Y_test_path))) 
  
  # Load train dataset as datatables.
  # Assign labels as documented in the features file.
  # However, remove characters that cannot directly be used in r command line
  
  renamed <- features$V2
  
  setnames (X_train, renamed)
  setnames (subject_train, "Subject")
  setnames (Y_train, "ActivityID")

  #  Load test dataset as datatables.
  #  Assign labels as documented in the features file
  
  setnames (X_test, features$V2)
  setnames (subject_test, "Subject")
  setnames (Y_test, "ActivityID")

  #
  #  keep only mean and std columns in X_train and X_test
  #
  #  keep <- grep ("*mean*|*std*", features$V2) 
  keep <- grep ("*mean\\(\\)*|*std*", features$V2) 
  X_train <- select(X_train, keep)
  X_test <- select(X_test, keep)
  
  #  append subject column and Y column to the features.
  har_train <- cbind(subject_train, Y_train, X_train )
  har_test <- cbind(subject_test, Y_test, X_test)
  
  #
  # Combine test and train datasets
  #
  
  har <- rbind (har_train, har_test)

  #
  # replace activity numbers with names
  #
  setnames(activities, c("ActivityID", "Activity"))
  setkey(activities, ActivityID)
  setkey(har, ActivityID)
  har <- merge(har, activities)
  har <- select (har, -ActivityID)
  
  #
  # rename columns. remove brackets, -
  #
  renamed <- names(har)
  renamed <- sub ("\\(\\)", "", renamed)
  renamed <- sub ("-", "_", renamed)
  renamed <- sub ("-", "_", renamed) 
  
  setnames(har, renamed)
  har
}


transform_har_data_table <- function (dt){
  dt <- copy(dt)  
  columns <- names (select (dt, -Subject, -Activity))
  
  sapply(columns, function(col){
    expr <- parse(text = paste0("m_", col, ":=mean(", col,")"))
    dt[,eval(expr),by=list(Subject, Activity)]
  } )
  
  dt <- select (dt, -one_of(columns))

  dt <- distinct (dt)
  dt [order(Subject, Activity)]
}
