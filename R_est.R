## Based on
## https://cmmid.github.io/topics/covid19/current-patterns-transmission/global-time-varying-transmission.html
## further adapted from
## https://github.com/aperaltasantos/covid_pt && https://cran.r-project.org/web/packages/EpiEstim/vignettes/demo.html
## Methods as described above
## Time-varying effective reproduction estimates were made with a 7-day sliding window using EpiEstim
## assuming an uncertain serial interval  with a mean of 4.7 days (95% CrI: 3.7, 6.0)
## and a standard deviation of 2.9 days (95% CrI: 1.9, 4.9).
### R_e calculation - Parametric SI method for

require(EpiEstim)
require(dplyr)
require(ggplot2)
require(RCurl)
require(reshape2)
require(purrr)
require(lubridate)

theme_set(theme_classic(base_size = 16))

data <- ntl.cases
data%>%select(Date,"cases"=cum.cases,"Deaths"=cum.deaths)->data
str(data)

data %>%
  select(Date,cases,Deaths) %>%
  melt(id.vars = 'Date') %>%
  ggplot(aes(Date,value,color=variable))+geom_line(size=2)+
  facet_wrap(~variable,nrow=2,scales='free')


## which data source do you want to use?
## confirmed = deaths or cases
data %>%
  mutate(Confirmed = cases) %>%
  select(Date,Confirmed) -> covid_pt


covid_pt<-covid_pt  %>%
  #subset(Date >= '2020-03-05') %>%
  mutate(epiweek = epiweek(Date))

first.date <- head(covid_pt$Date,1)

covid_pt %>%
  mutate(
    Confirmed_lag = lag(x = Confirmed,
                        n = 1,
                        order_by = Date),
    Confirmed_var=Confirmed-Confirmed_lag,
    Confirmed_sign=if_else(Confirmed_var>=0,"+","-")
  ) %>%
  subset(Date >  first.date) -> covid_pt

covid_pt  %>%
  select(
    Date,Confirmed_var
  )  %>%
  dplyr::mutate(
    t_start = dplyr::row_number() %>% as.numeric(),
    t_end = t_start + 6
  ) -> covid_r

## set negative daily counts to zero
covid_r$Confirmed_var[ covid_r$Confirmed_var < 0 ] <- 0

## parametric estimate given 'known' SI (no CIs)
res_parametric_si <-
  estimate_R(
    covid_r$Confirmed_var,
    method ="parametric_si",
    config = make_config(
      list(
        mean_si = 4.7,
        std_si = 2.9
      )
    )
  )

plot(res_parametric_si, legend = FALSE)

r_prt <- as.data.frame(res_parametric_si$R)


### join by t-end
left_join(
  x = covid_r,
  y = dplyr::select(
    r_prt,
    c("t_end", "Mean(R)", "Quantile.0.025(R)", "Quantile.0.975(R)")
  ),
  by = c("t_start" = "t_end")
) -> r_prt


r_prt %>%
  dplyr::rename(
    reff = "Mean(R)",
    r_low = "Quantile.0.025(R)",
    r_high = "Quantile.0.975(R)"
  ) -> r_prt


r_prt %>%
  ggplot(aes(Date,reff)) +
  geom_line()+
  #geom_point()+
  geom_hline( yintercept=1) +
  geom_ribbon(aes(Date, ymin = r_low, ymax = r_high),alpha=0.3) +
  scale_x_date(breaks='7 days') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1) )+
  ggtitle("COVID-19 Effective reproduction")->Reest
ggplotly(Reest)

## R_e calculation - allowing for uncertainity in SI
## use mean 4.7 (95% CrI: 3.7, 6.0)
## use sd 2.9 (95% CrI: 1.9, 4.9)
sens_configs <-
  make_config(
    list(
      mean_si = 4.7, std_mean_si = 0.7,
      min_mean_si = 3.7, max_mean_si = 6.0,
      std_si = 2.9, std_std_si = 0.5,
      min_std_si = 1.9, max_std_si = 4.9,
      n1 = 1000,
      n2 = 100,
      seed = 123456789
    )
  )

Rt_nonparam_si <-
  estimate_R(
    covid_r$Confirmed_var,
    method = "uncertain_si",
    config = sens_configs
  )

## inspect R_e estimate
#plot(Rt_nonparam_si, legend = FALSE)

## Posterior sample R_e estimate
sample_windows <- seq(length(Rt_nonparam_si$R$t_start))
#sample_windows <- Rt_nonparam_si$dates

posterior_R_t <-
  map(
    .x = sample_windows,
    .f = function(x) {
      
      posterior_sample_obj <-
        sample_posterior_R(
          R = Rt_nonparam_si,
          n = 1000,
          window = x
        )
      
      posterior_sample_estim <-
        data.frame(
          window_index = x,
          window_t_start = Rt_nonparam_si$R$t_start[x],
          window_t_end = Rt_nonparam_si$R$t_end[x],
          date_point = covid_r[covid_r$t_start == Rt_nonparam_si$R$t_end[x], "Date"],
          Confirmed = covid_pt[covid_r$t_start == Rt_nonparam_si$R$t_end[x], "Confirmed"],
          R_e_median = median(posterior_sample_obj),
          R_e_q0025 = quantile(posterior_sample_obj, probs = 0.025,na.rm = T),
          R_e_q0975 = quantile(posterior_sample_obj, probs = 0.975,na.rm = T)
        )
      
      return(posterior_sample_estim)
      
    }
  ) %>%
  reduce(bind_rows)


posterior_R_t

posterior_R_t %>%
  ggplot(aes(x = Date, y = R_e_median)) +
  geom_line(alpha = 0.3, size = 1.2) +
  geom_ribbon(aes(ymin = R_e_q0025, ymax = R_e_q0975), alpha = 0.1) +
  scale_x_date(breaks='7 days') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1) )+
  geom_hline(yintercept = 1)+
  ggtitle("COVID-19 Effective reproduction")+
  ylab(bquote(R[e]))+xlab(NULL)

