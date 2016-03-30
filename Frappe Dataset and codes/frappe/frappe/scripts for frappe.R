#this is the script for Frappe dataset to check 
#my proposed approach on another dataset On March 2016

#read data file
frappe <- read.delim("D:/parisa/open datasets/baltrunas/frappe/frappe/frappe.csv")


#Descriptives
hist(as.numeric(frappe$daytime), main= "Distribution of daytime", xlab="Day time")
hist(as.numeric(frappe$weekday), main= "Distribution of weekday", xlab="weekday")
hist(as.numeric(frappe$isweekend), main= "Distribution of weekend", xlab="weekend?")
hist(as.numeric(frappe$homework), main= "Distribution of home/work/unknown", xlab="location")
hist(as.numeric(frappe$cost), main= "Distribution of cost", xlab="cost")
hist(as.numeric(frappe$weather), main= "Distribution of weather", xlab="weather")
hist(as.numeric(frappe$country), main= "Distribution of country", xlab="country")


##
#calculating entropy for time- the normalized version(nentr) should be between 0 and 1
  
a<- na.omit(frappe$city)

summary(a)
myfreqs <- table(a)/length(a)
# vectorize
myvec <- as.data.frame(myfreqs)[,2]
# H in bit
entr<- -sum(myvec * log2(myvec))
entr
nentr<- entr/log2(length(a))
nentr

#transforming counts into ratings
#1-3= 1, 4-24=2, 25-100=3, 101-499=4, >=500=5
frappe$rating<-frappe$cnt

attach(frappe)
frappe$cnt[cnt > 0 & cnt <= 3] <- "1"
frappe$cnt[cnt > 3 & cnt <= 24] <- "2"
frappe$cnt[cnt > 24 & cnt <= 100] <- "3"
frappe$cnt[cnt > 100 & cnt <= 499] <- "4"
frappe$cnt[cnt >= 500 ] <- "5"
detach(frappe)

#renaming rating and count
library(reshape)
frappe <- rename(frappe, c(cnt="ratings"))
frappe <- rename(frappe, c(rating="cnt"))

hist(frappe$rating)
table(frappe$ratings)

#contextual data preparation for Weka
contextdata<- frappe[,3:11]
contextdata$daytime <- as.factor(contextdata$daytime)
contextdata$weekday <- as.factor(contextdata$weekday)
contextdata$isweekend <- as.factor(contextdata$isweekend)
contextdata$homework <- as.factor(contextdata$homework)
contextdata$cost <- as.factor(contextdata$cost)
contextdata$weather <- as.factor(contextdata$weather)
contextdata$ratings <- as.factor(contextdata$ratings)
contextdata$country <- as.factor(contextdata$country)
contextdata$city <- as.factor(contextdata$city)

#write the contextual data file for the use in weka
write.csv(contextdata,"D:/parisa/open datasets/baltrunas/frappe/frappe/contextdata.csv")
write.csv(frappe,"D:/parisa/open datasets/baltrunas/frappe/frappe/frappenew.csv")

#using Rweka for gain ratio calculation
library(RWeka)
#information gain value
InfoGainAttributeEval(ratings ~ . , data = contextdata)
#gain ratio value
GainRatioAttributeEval(ratings~ ., data = contextdata)


#preparing data for matlab
frappe <- read.csv("D:/parisa/open datasets/baltrunas/frappe/frappe/frappenew.csv")

#user=0 should be changed to user = 957
#item = 0 should be changed to item = 4082
attach(frappe)
frappe$user[user == 0 ] <- "957"
frappe$item[item == 0] <- "4082"
frappe$city[city == 0] <- "1088"
detach(frappe)
#changing contextual features to numeric

frappe$daytime <- as.numeric(frappe$daytime)
frappe$weekday <- as.numeric(frappe$weekday)
frappe$isweekend <- as.numeric(frappe$isweekend)
frappe$homework <- as.numeric(frappe$homework)
frappe$cost <- as.numeric(frappe$cost)
frappe$weather <- as.numeric(frappe$weather)
frappe$ratings <- as.numeric(frappe$ratings)
frappe$country <- as.numeric(frappe$country)
frappe$city <- as.numeric(frappe$city)
frappe$user <- as.numeric(frappe$user)
frappe$item <- as.numeric(frappe$item)

write.csv(frappe,"D:/parisa/open datasets/baltrunas/frappe/frappe/frappematlab.csv")
-------------------------------------
#analyzing the RMSE results for single feature
RMSEdata <- read.csv("D:/parisa/open datasets/baltrunas/frappe/frappe/RMSE for analysis.csv") 
boxplot(RMSEdata,ylim = c(0.83, 0.96), ylab="RMSE", lab="RMSE for features", las=1, medcol="white")
means = colMeans(RMSEdata)
points(means) 
abline(h =0.9532, col = "red")

t.test(RMSEdata$no.context, RMSEdata$weather)
t.test(RMSEdata$country, RMSEdata$weekday)

-------------------------------------------
###I used weka for this###
  #decision tree
library(RWeka)
library(PlayerRatings)
m1 <- J48(ratings~., data = contextdata)
plot(m1)


