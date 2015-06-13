activity <- read.csv(unzip("RepData_PeerAssessment1/activity.zip", exdir="."))
#Mean total steps per day
complete <- activity[complete.cases(activity$steps),]
library(plyr)
StepsPerDay <- ddply(complete, ~date, summarise, total=sum(steps), mean=mean(steps), sd=sd(steps))
hist(StepsPerDay$total, col="red", xlab="Total steps per day")

#Average daily activity pattern
complete <- activity[complete.cases(activity$steps),]
StepsPerInterval <- ddply(complete, ~interval, summarise, mean=mean(steps), na.rm=TRUE)
with(StepsPerInterval, plot(interval, mean, type="l", ylab="Average number of steps"))

StepsPerInterval$interval[StepsPerInterval$mean==max(StepsPerInterval$mean)]

#inputting missing values
##number of incomplete rows (i.e. rows with NAs)
NA_rows <- sum(is.na(activity))
##
activity_noNA <- na.omit(activity)
avgSteps <- aggregate(activity_noNA$steps, by=list(activity_noNA$interval), data = activity_noNA, FUN = "mean")
names(avgSteps) <- c("interval", "meanSteps")
activity_new <- activity
for (i in 1:nrow(activity_new)) {
  if (is.na(activity_new$steps[i])) {
    activity_new$steps[i]<- avgSteps[which(activity_new$interval[i] == avgSteps$interval), ]$mean
  }
}

head(activity_new)
sum(is.na(activity_new))
#make histogram of the activity with missibg values replaced
new_StepsPerDay <- ddply(activity_new, ~date, summarise, total=sum(steps), mean=mean(steps), sd=sd(steps))
hist(new_StepsPerDay$total, col="red", xlab="Total steps per day")

#Are there differences in activity patterns between weekdays and weekends?
day <- weekdays(as.Date(activity_new$date))
dayType <- vector()
for (i in 1:nrow(activity_new)) {
  if (day[i] == "Saturday"|day[i] == "Sunday") {
    dayType[i] <- "Weekend"
  } else {
    dayType[i] <- "Weekday"
  }
}
activity_new$dayType <- factor(dayType)
new_StepsPerInterval<- aggregate(steps ~ interval + dayType, data = activity_new, mean)
names(new_StepsPerInterval) <- c("interval", "dayType", "steps")
library(lattice)
xyplot(steps ~ interval | dayType, new_StepsPerInterval, type = "l", layout = c(1, 2), 
       xlab = "Interval", ylab = "Number of steps")