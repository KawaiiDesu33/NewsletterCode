setwd("/___")


### Installing and Loading Packages
#install.packages("readxl")
#install.packages("broom")
#install.packages("dplyr")
#install.packages("plyr")
#install.packages("ggpubr")
#install.packages("car")
#install.packages("ggplot2")

library("readxl")
library("dplyr")
library("plyr")
library("broom")
library("ggpubr")
library("car")
library("ggplot2")

### Setting Data
data = as.data.frame(read_excel("/____", 
                                sheet = "Benchmarking Data", range = "A2:BD550"))

### Summarising Data
summary(data) #Treated Dashes as characters 

### Converting Mistyped Data
data$`Fair Value TFR` = as.numeric(data$`Fair Value TFR`)
data$`Target Fair Value STI` = as.numeric(data$`Target Fair Value STI`)
data$`Target Fair Value LTI` = as.numeric(data$`Target Fair Value LTI`)

data$`Fair Value TFR + Target Fair Value STI + Target Fair Value LTI + Fair Value LTE`= as.numeric(data$`Fair Value TFR + Target Fair Value STI + Target Fair Value LTI + Fair Value LTE`)
data$`Maximum Fair Value STI` = as.numeric(data$`Maximum Fair Value STI`)
data$`Maximum Fair Value LTI` = as.numeric(data$`Maximum Fair Value LTI`)
data$`Fair Value LTE...20` = as.numeric(data$`Fair Value LTE...20`)
data$`Fair Value TFR + Maximum Fair Value STI + Maximum Fair Value LTI + Fair Value LTE` = as.numeric(data$`Fair Value TFR + Maximum Fair Value STI + Maximum Fair Value LTI + Fair Value LTE`)

data$`Diluted EPS from Continuing Operations (AU$)` = as.numeric(data$`Diluted EPS from Continuing Operations (AU$)`)
data$`Personnel Expense (AU$m)` = as.numeric(data$`Personnel Expense (AU$m)`)
data$`EBIT (AU$m)` = as.numeric(data$`EBIT (AU$m)`)
data$`EBITA (AU$m)`= as.numeric(data$`EBITA (AU$m)`)
data$`EBITDA (AU$m)`= as.numeric(data$`EBITDA (AU$m)`)
data$`CEO age`= as.numeric(data$`CEO age`)
data$`1 year Enterprise Value (AU$m)` = as.numeric(data$`1 year Enterprise Value (AU$m)`)

#Calculation of Incentive
data$`Target Fair Value STI`[is.na(data$`Target Fair Value STI`)] = 0
data$`Target Fair Value LTI`[is.na(data$`Target Fair Value LTI`)] = 0
data$`Fair Value LTE...20`[is.na(data$`Fair Value LTE...20`)] = 0

data$`Maximum Fair Value STI`[is.na(data$`Maximum Fair Value STI`)] = 0
data$`Maximum Fair Value LTI`[is.na(data$`Maximum Fair Value LTI`)] = 0

target_incentive = data$`Target Fair Value STI` + data$`Target Fair Value LTI` + data$`Fair Value LTE...20` 
max_incentive = data$`Target Fair Value STI` + data$`Target Fair Value LTI` + data$`Fair Value LTE...20`

data$target_incentive = target_incentive
data$max_incentive = max_incentive

#Renaming Columns
colnames(data)

colnames(data)[colnames(data)=="Fair Value TFR + Maximum Fair Value STI + Maximum Fiar Value LTI + Fair Value LTE"] = "Max TR"
colnames(data)[colnames(data)=="1 year Market Capitalisation (AU$m)"] = "Market Cap"
colnames(data)[colnames(data)=="1 year Enterprise Value (AU$m)"] = "EV"
colnames(data)[colnames(data)=="Diluted EPS from Continuing Operations (AU$)"] = "Diluted EPS"
colnames(data)[colnames(data)=="Free Cash Flow (AU$m)"] = "FCF"
colnames(data)[colnames(data)=="Fair Value TFR + Target Fair Value STI + Target Fair Value LTI + Fair Value LTE"] = "Target TR"
colnames(data)[colnames(data)=="Fair Value TFR + Maximum Fair Value STI + Maximum Fair Value LTI + Fair Value LTE"] = "Max TR"

### Spliting necessary Data - Removing other NA Execs Data
execs_data = subset(data, data$CEO == "N")
execs_data$`Fair Value TFR`[is.na(execs_data$`Fair Value TFR`)] == "-"
execs_data = subset(execs_data, execs_data$`Fair Value TFR` != "-")

str(execs_data)

### Graphing
gghistogram(execs_data$`Fair Value TFR`, bins = 40)
gghistogram(execs_data$`Max TR`, bins = 40)
gghistogram(execs_data$target_incentive, bins = 40)
gghistogram(execs_data$max_incentive, bins = 40)

# Logging Financials
lm_cap = log(execs_data$`Market Cap`)
ltot_ass = log(execs_data$`Total Assets (AU$m)`)
ltot_lia = log(execs_data$`Total Liabilities (AU$m)`)

#Adjusting Negative Logs
lnet_ass = log(execs_data$`Net Assets (AU$m)` - pmin(0, execs_data$`Net Assets (AU$m)`)+1)
lpretax = log(execs_data$`Pre-tax Profit (AU$m)` - pmin(0, execs_data$`Pre-tax Profit (AU$m)`)+1)
lcashops = log(execs_data$`Cash from Operations (AU$m)` - pmin(0, execs_data$`Cash from Operations (AU$m)`)+1)
lev = log(execs_data$EV - pmin(0, execs_data$EV)+1)
lrev = log(execs_data$`Revenue (AU$m)` - pmin(0, execs_data$`Revenue (AU$m)`)+1)
lEBITDA = log(execs_data$`EBITDA (AU$m)` - pmin(0, execs_data$`EBITDA (AU$m)`)+1)
lEBITA = log(execs_data$`EBITA (AU$m)` - pmin(0, execs_data$`EBITA (AU$m)`)+1)
lEBIT = log(execs_data$`EBIT (AU$m)` - pmin(0, execs_data$`EBIT (AU$m)`)+1)
lpretax = log(execs_data$`Pre-tax Profit (AU$m)` - pmin(0, execs_data$`Pre-tax Profit (AU$m)`)+1)
lNPAT = log(execs_data$`NPAT (AU$m)`- pmin(0, execs_data$`NPAT (AU$m)`)+1)
lFCF = log(execs_data$FCF- pmin(0, execs_data$FCF)+1)
ldiluted_eps = log(execs_data$`Diluted EPS` - pmin(0, execs_data$`Diluted EPS`) + 1)
lpersonal_exp = log(execs_data$`Personnel Expense (AU$m)` - pmin(0, execs_data$`Personnel Expense (AU$m)`) + 1)

#Merging to CEO Data
execs_data$lm_cap = lm_cap
execs_data$lev = lev
execs_data$ltot_ass = ltot_ass
execs_data$ltot_lia = ltot_lia
execs_data$lnet_ass = lnet_ass
execs_data$lrev = lrev
execs_data$lpretax = lpretax
execs_data$lnpat = lNPAT
execs_data$lcashops = lcashops
execs_data$lFCF = lFCF
execs_data$lpersonal_exp = lpersonal_exp
execs_data$ldiluted_eps = ldiluted_eps

#Replacing values
execs_data$`Maximum Fair Value STI`[is.na(execs_data$`Maximum Fair Value STI`)] = 0
execs_data$`Maximum Fair Value LTI`[is.na(execs_data$`Maximum Fair Value LTI`)] = 0

#Correlation
quant_fins = data.frame(execs_data$`Fair Value TFR`, execs_data$lm_cap, execs_data$lev, execs_data$ltot_ass, 
                        execs_data$ltot_lia, execs_data$lnet_ass, execs_data$lrev, execs_data$lpretax, 
                        execs_data$lcashops, execs_data$lFCF, execs_data$lpersonal_exp, 
                        execs_data$ldiluted_eps)
quant_corr = cor(quant_fins)

#Scatter Plots
scatterplot(execs_data$`Fair Value TFR`, execs_data$lm_cap, data = execs_data$Gender)

#TFR Plot
clean_data = subset(execs_data, execs_data$`Fair Value TFR`!= "-")
ggplot(clean_data, aes(x = clean_data$`Market Cap`, y = clean_data$`Fair Value TFR`, color = clean_data$Gender)) +
  geom_point() +
  labs(x = "Market Capitalisation", y = "Total Fixed Remuneration") + 
  scale_color_discrete("Gender")

ggplot(clean_data, aes(x = clean_data$`Market Cap`, y = clean_data$`Fair Value TFR`, color = clean_data$Gender)) +
  geom_point() +
  labs(x = "Log Market Capitalisation ($M)", y = "Total Fixed Remuneration ($)") + 
  scale_color_discrete("Gender") +
  scale_y_continuous(breaks = seq(0, max(clean_data$`Fair Value TFR`), 200000), labels = scales::dollar) + 
  scale_x_continuous(trans = "log10", labels = scales::dollar)

#Max TR Plot
clean_data = execs_data
clean_data$`Max TR`[is.na(clean_data$`Max TR`)] == "-"
clean_data = subset(clean_data, clean_data$`Max TR` != "-")
ggplot(clean_data, aes(x = clean_data$`Market Cap`, y = clean_data$`Max TR`, color = clean_data$Gender)) + 
  geom_point() + 
  labs(x = "Log Market Capitalisation ($M)", y = "Maximum Total Remuneration ($)") +
  scale_color_discrete("Gender") +
  scale_y_continuous(breaks = seq(0, max(clean_data$`Max TR`), 2000000), labels = scales::dollar) +
  scale_x_continuous(trans = "log10", labels = scales::dollar)

#Incentive Opportunity Plot
clean_data = execs_data
clean_data$target_incentive[is.na(clean_data$target_incentive)] == "-"
clean_data = subset(clean_data, clean_data$target_incentive != "-")

ggplot(data = clean_data, aes(x = clean_data$lrev, y = clean_data$target_incentive, color = clean_data$Gender)) +
  geom_point() +
  labs(x = "Log Revenue ($M)", y = "Target Incentive") +
  scale_color_discrete("Gender") +
  scale_x_continuous(breaks = seq(0, max(clean_data$lrev), 200000), labels = scales::dollar) +
  scale_y_continuous(trans = "log10", labels = scales::dollar)

ggplot(data = clean_data, aes(x = clean_data$`Market Cap`, y = clean_data$max_incentive, color = clean_data$Gender))+
  geom_point()+
  labs(x = "Log Market Capitalisation ($M)", y = "Maximum Incentive ($)")+
  scale_color_discrete("Gender") + 
  scale_y_continuous(breaks = seq(0, max(clean_data$max_incentive), 2000000), labels = scales::dollar)+
  scale_x_continuous(trans = "log10", labels = scales::dollar)


# TFR Regression - No Significance
#TFR_reg = lm(execs_data$`Fair Value TFR` ~ execs_data$Gender + execs_data$`Tenure - Years` + lm_cap + lev + ltot_ass + ltot_lia + lnet_ass + lrev +
#              lEBITDA + lEBITA + lEBIT + lpretax + lNPAT + lcashops + lFCF + lpersonal_exp + 
#             ldiluted_eps,
#      na.action = na.omit)
#summary(TFR_reg)
#predict_reg = predict(TFR_reg)
#plot(TFR_reg)

#Regression including MQG
TFR_lreg = lm(`Fair Value TFR` ~ Gender + `Tenure - Years` + `GICS Sector` +
                lm_cap + lev + ltot_ass + ltot_lia + lnet_ass + lrev +
                lpretax + lnpat + lFCF + ldiluted_eps, data=execs_data, na.action = na.omit)
summary(TFR_lreg)
plot(TFR_lreg)

# Regressing by role as well
TFR_role_lreg = lm(data = execs_data, `Fair Value TFR` ~ Gender + `Summarised Role`+ `Tenure - Years` +
                     `GICS Sector` + lm_cap + lev + ltot_ass + ltot_lia + lnet_ass +
                     lrev + lpretax + lnpat + lFCF + ldiluted_eps, na.action =  na.omit)
summary(TFR_role_lreg)
plot(TFR_role_lreg)

# Total Max TR Regression - No Significance
#TotalMax_TR_reg = lm(execs_data$`Fair Value TFR + Maximum Fair Value STI + Maximum Fair Value LTI + Fair Value LTE`~ execs_data$Gender+ execs_data$`GICS Sector`+ execs_data$`1 year Market Capitalisation (AU$m)`+ 
#               execs_data$`1 year Enterprise Value (AU$m)`+ execs_data$`Total Assets (AU$m)`+ execs_data$`Total Liabilities (AU$m)`+ 
#              execs_data$`Net Assets (AU$m)`+ execs_data$`Revenue (AU$m)`+ execs_data$`EBITDA (AU$m)`+ execs_data$`EBITA (AU$m)`+ 
#             execs_data$`EBIT (AU$m)`+ execs_data$`Pre-tax Profit (AU$m)`+ execs_data$`NPAT (AU$m)`+ execs_data$`Cash from Operations (AU$m)`+
#            execs_data$`Free Cash Flow (AU$m)`+ execs_data$`Personnel Expense (AU$m)`+ execs_data$`Diluted EPS from Continuing Operations (AU$)`,
#         na.action = na.omit)
#summary(TotalMax_TR_reg)
#predict_reg = predict(TotalMax_TR_reg)
#plot(TotalMax_TR_reg)

MaxTR_lreg = lm(execs_data$`Max TR` ~ execs_data$Gender + execs_data$`Tenure - Years` + execs_data$`GICS Sector` +
                  lm_cap + lev + ltot_ass + ltot_lia + lnet_ass + lrev +
                  lpretax + lnpat + lFCF + ldiluted_eps, data = execs_data,  na.action = na.omit)
summary(MaxTR_lreg)
plot(MaxTR_lreg)

# Total Incentive Opportunities Regression

#incentive_reg = lm(execs_data$`Maximum Fair Value LTI` ~ execs_data$Gender+ execs_data$`GICS Sector`+ execs_data$`1 year Market Capitalisation (AU$m)`+ 
#                      execs_data$`1 year Enterprise Value (AU$m)`+ execs_data$`Total Assets (AU$m)`+ execs_data$`Total Liabilities (AU$m)`+ 
#                     execs_data$`Net Assets (AU$m)`+ execs_data$`Revenue (AU$m)`+ execs_data$`EBITDA (AU$m)`+ execs_data$`EBITA (AU$m)`+ 
#                    execs_data$`EBIT (AU$m)`+ execs_data$`Pre-tax Profit (AU$m)`+ execs_data$`NPAT (AU$m)`+ execs_data$`Cash from Operations (AU$m)`+
#                   execs_data$`Free Cash Flow (AU$m)`+ execs_data$`Personnel Expense (AU$m)`+ execs_data$`Diluted EPS from Continuing Operations (AU$)`,
#                na.action = na.omit)

incen_reg = lm(execs_data$max_incentive ~ `Gender` + `Tenure - Years` + `GICS Sector` +
                 lm_cap + lev + ltot_ass + ltot_lia + lnet_ass + lrev +
                 lpretax + lNPAT + lFCF + ldiluted_eps, data = execs_data, na.action = na.omit)
summary(incen_reg)
predict_reg = predict(incen_reg)
plot(incen_reg)

summary(TFR_lreg)
summary(MaxTR_lreg)
summary(incen_reg)




#Plotting BUH Gender Difference
BUH_data = subset(execs_data, execs_data$`Summarised Role` == "BUH")

ggplot(data = BUH_data, aes(x = BUH_data$`Market Cap`, y = `Fair Value TFR`, color = Gender))+
  geom_point() + 
  labs(x = "Log Market Capitalisation ($M)", y = "Total Fixed Remuneration") +
  scale_color_discrete("Gender") + 
  scale_y_continuous(breaks = seq(0, max(clean_data$max_incentive), 200000), labels = scales::dollar)+
  scale_x_continuous(trans = "log10", labels = scales::dollar)

#Plotting CFO Gender Difference
CFO_data = subset(execs_data, execs_data$`Summarised Role` == "CFO")

ggplot(data = CFO_data, aes(x = `Market Cap`, y = `Fair Value TFR`, color = Gender))+
  geom_point() +
  labs(x = "Log Market Capitalisation ($M)", y = "Total Fixed Remuneration ($)") +
  scale_color_discrete("Gender") +
  scale_x_continuous(trans = "log10", labels = scales::dollar) +
  scale_y_continuous(breaks = seq(0, max(CFO_data$`Fair Value TFR`), 200000), labels = scales::dollar)

