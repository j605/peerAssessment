library(data.table)
library(dplyr)
library(magrittr)

data.dir <- "UCI HAR Dataset"

# Stop if not in the correct directory
stopifnot(data.dir %in% dir())

# Setup directory names
train.dir <- paste(data.dir, "train", sep="/")
train.signal.dir <- paste(train.dir, "Inertial Signals", sep="/")
test.dir <- paste(data.dir, "test", sep="/")
test.signal.dir <- paste(test.dir, "Inertial Signals", sep="/")

features <- fread(paste(data.dir, "features.txt", sep="/"))
activity.labels <- fread(paste(data.dir, "activity_labels.txt", sep="/"))

# Read training data
train.labels <- fread(paste(train.dir, "y_train.txt", sep="/"))
# Use read.table as fread segfaults due to different spaces in the document
train.data <- read.table(paste(train.dir , "X_train.txt", sep="/")
                         , header=F, colClasses="numeric")
train.data <- as.data.table(train.data)

# Set descriptive names
setnames(train.data, features[, V2])
train.subject <- fread(paste(train.dir, "subject_train.txt", sep="/"))
train.data <- train.data[, grepl("mean|std", colnames(train.data), perl=T)
                         , with=F]
train.data <- mutate(train.data,
                     activity=activity.labels[, V2][train.labels[, V1]],
                     subject=train.subject)

# Read testing data
test.labels <- fread(paste(test.dir, "y_test.txt", sep="/"))
test.data <- read.table(paste(test.dir , "X_test.txt", sep="/"),
                        header=F, colClasses="numeric")
test.data <- as.data.table(test.data)
test.subject <- fread(paste(test.dir, "subject_test.txt", sep="/"))
setnames(test.data, features[, V2])
test.data <- test.data[, grepl("mean|std", colnames(test.data), perl=T)
                       , with=F]
test.data <- mutate(test.data, activity=activity.labels[, V2][test.labels[, V1]],
                    subject=test.subject)

# Merge training and testing data
tidyData <- rbindlist(list(train.data, test.data), use.names=T)

# Group by subject and activity and take mean of all variables
tidyData %>%
    group_by(subject, activity) %>%
    summarise_each(funs(mean)) %>%
    write.table(file = "tidyData.txt",
                row.names = F)
