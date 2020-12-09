# 1 The submitted data set is tidy.
# 2 The Github repo contains the required scripts.
# 3 GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
# 4 The README that explains the analysis files is clear and understandable.
# 5 The work submitted for this project is the work of the student who submitted it.

library(data.table)
library(reshape2)
# Create data folder into project directory.
path <- file.path(getwd(), "data")
url <-
  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = file.path(path, "dataFiles.zip"))
# move unzipped to /data

# Load labels and features
activityLabels <-
  fread(
    file.path(path, "UCI HAR Dataset/activity_labels.txt")
    ,
    col.names = c("classLabels", "activityName")
  )
features <- fread(
  file.path(path, "UCI HAR Dataset/features.txt")
  ,
  col.names = c("index", "featureNames")
)
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load train data
train <-
  fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <-
  fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
        ,
        col.names = c("Activity"))
trainSubjects <-
  fread(
    file.path(path, "UCI HAR Dataset/train/subject_train.txt")
    ,
    col.names = c("SubjectNum")
  )
train <- cbind(trainSubjects, trainActivities, train)

# Load test data
test <-
  fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <-
  fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
        ,
        col.names = c("Activity"))
testSubjects <-
  fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
        ,
        col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merge data
merged <- rbind(train, test)


# Add levels as Factor to classLabels and activityName
merged[["Activity"]] <- factor(merged[, Activity]
                               , levels = activityLabels[["classLabels"]]
                               , labels = activityLabels[["activityName"]])

merged[["SubjectNum"]] <- as.factor(merged[, SubjectNum])
merged <-
  reshape2::melt(data = merged, id = c("SubjectNum", "Activity"))
merged <-
  reshape2::dcast(data = merged,
                  SubjectNum + Activity ~ variable,
                  fun.aggregate = mean)

write.table(
  merged,
  file = file.path(path, "tidyData.txt"),
  row.names = FALSE,
  col.names =  TRUE
) 
