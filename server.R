

function(input,output,session){
  
  
  
  output$acct_info1<-renderTable(
    if(!is.null(input$data_f))
      input$data_f
  )
  
  dfff<-reactiveValues(data = NULL)
  withdraw<-reactiveValues(data = NULL)
  withdraw_plot<-reactiveValues(data = NULL)
  deposit<-reactiveValues(data = NULL)
  deposit_plot<-reactiveValues(data = NULL)
  total<-reactiveValues()
  output$total_debit<-renderText(total$debit)
  output$total_credit<-renderText(total$credit)
  output$avg_balance<-renderText(total$avgBalance)
  
  data_file<-reactive({
    if(is.null(input$data_f)){return()}
    else{
      #taking file input
      file_spec<-input$data_f
      Acct_Statement <- read_excel(file_spec$datapath)
      
      #snipping the main transaction data
      r<-nrow(Acct_Statement)
      r<-r-18
      df<-data.frame(
        Acct_Statement[c(22:r),]
      )
      
      #storing data in different data frame
      dff<-data.frame(
        Date=as.Date(df$HDFC.BANK.Ltd.......................................Page.No......1..........................................Statement.of.accounts, format="%d/%m/%Y"),
        Narration=df$...2,
        Withdraw_amt=as.numeric(df$...5),
        Deposit_amt=as.numeric(df$...6),
        Balance_amt=as.numeric(df$...7)
      )
      
      #filtering only UPI data
      dff<-dff[dff$Narration %like% "UPI",]
      
      #filtering out name from the narration
      for (i in 1:nrow(dff)) {
        st<-dff[i,2]
        arr<-strsplit(st,split = '-')
        dff[i,2]<-arr[[1]][2]
      }
      dfff$data=dff
      
      #separating withdrawal amount and grouping them
      withdr<-dfff$data[!is.na(dfff$data$Withdraw_amt),c(2,3)]
      withdr<- withdr %>% group_by(Narration) %>% summarise(across(Withdraw_amt, sum))
      withdraw$data<-withdr
      
      #separating deposit amount and grouping them
      depo<-dfff$data[!is.na(dfff$data$Deposit_amt),c(2,4)]
      depo<- depo %>% group_by(Narration) %>% summarise(across(Deposit_amt,sum))
      deposit$data<-depo
      
      #finding total Debit and credit
      total$debit<-sum(depo$Deposit_amt)
      total$credit<-sum(withdr$Withdraw_amt)
      
      #Average balance
      total$avgBalance<-mean(dff$Balance_amt)
      
      return(dff)
    }
  })
  
  output$acct_info2<-renderDataTable({
    data_file()
  })
  
  output$withdraw<-renderDataTable({
    withdraw$data
  })
  
  output$deposit<-renderDataTable({
    deposit$data
  })
  
  
  data_file_withdraw_comp<-reactive({
    withdr<-withdraw$data
    withdraw_sum<-total$debit
    thres<-withdraw_sum*0.02
    withdraw_comp<-filter(withdr,Withdraw_amt>thres)
    other = 0;
    for(i in withdr$Withdraw_amt)
    {
      if(i<withdraw_sum*0.02)
        other=other + i
    }
    withdraw_comp<-rbind(withdraw_comp,c("Others",other))
    withdraw_plot$data<- data.frame(
      Narration = withdraw_comp$Narration,
      Withdraw_amt = as.numeric(withdraw_comp$Withdraw_amt)
    )
    withdraw_plot$data$Withdraw_amt<- as.numeric(withdraw_plot$data$Withdraw_amt)
    
    return(withdraw_plot$data)
  })
  
  output$debit <- renderPlotly(plot_ly(data_file_withdraw_comp(), labels = ~Narration, values = ~Withdraw_amt, type = 'pie')
                             )
  
  data_file_deposit_comp<-reactive({
    cred<-deposit$data
    cred_sum<-sum(cred$Deposit_amt)
    total$credit<-cred_sum
    thres<-cred_sum*0.02
    cred_comp<-filter(cred,Deposit_amt>thres)
    other = 0;
    for(i in cred$Deposit_amt)
    {
      if(i<cred_sum*0.02)
        other=other + i
    }
    cred_comp<-rbind(cred_comp,c("Others",other))
    deposit_plot$data<- data.frame(
      Narration = cred_comp$Narration,
      Deposit_amt = as.numeric(cred_comp$Deposit_amt)
    )
    return(deposit_plot$data)
  })
  
  output$credit <- renderPlotly(plot_ly(data_file_deposit_comp(), labels = ~Narration, values = ~Deposit_amt, type = 'pie')
                             )
  
  data_file_balance<-reactive({
    balance<-data.frame(
      Date=as.Date(dfff$data$Date),
      Balance_amt=dfff$data$Balance_amt
    )
    return(balance)
  })
  
  output$balance <- renderPlotly(plot_ly(data_file_balance(), x = ~Date, y = ~Balance_amt, type = 'scatter', mode = 'lines'))
  
}