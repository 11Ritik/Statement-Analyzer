dashboardPage(
  dashboardHeader(title="Transaction Analyzer", titleWidth = 250, 
                  tags$li(class="dropdown",tags$a(href="#", icon("youtube"), "My Channel", target="_blank")),
                  tags$li(class="dropdown",tags$a(href="https://www.linkedin.com/in/ritik-singh-078174201/" ,icon("linkedin"), "My Profile", target="_blank")),
                  tags$li(class="dropdown",tags$a(href="#", icon("github"), "Source Code", target="_blank"))
  ),
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem(text = "Dataset", tabName = "data",icon=icon("database")),
      menuItem(text = "visualization",tabName = "viz" , icon =icon("database")),
      menuItem(text = "Analysis",tabName = "anal" , icon =icon("database"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "data",
              tabBox(id="t1",width=12,
                     sidebarLayout(position = "left",
                                   sidebarPanel(fileInput("data_f","upload your bank statement")),
                                   mainPanel(
                                     tableOutput("acct_info1")
                                   )
                     ),
                     tabPanel(title = "All",value="relation",dataTableOutput("acct_info2")),
                     tabPanel(title = "Deposit",value="trends",dataTableOutput("deposit")),
                     tabPanel(title = "Withdraw",value="trends",dataTableOutput("withdraw"))
              )
      ),
      tabItem(tabName = "viz",
              tabBox(id="t2",width = 12,
                     tabPanel(title = "Debit",value="trends",h1("Debit Composition"),shinycssloaders::withSpinner(plotlyOutput("debit"))),
                     tabPanel(title = "Credit",value="trends",h1("Credit Composition"),shinycssloaders::withSpinner(plotlyOutput("credit"))),
                     tabPanel(title = "Balance",value="relation",h1("Bank Balance Timeline",align="center"),shinycssloaders::withSpinner(plotlyOutput("balance")))
              )
      ),
      tabItem(tabName = "anal",
              box(width = 12,
                strong("Total Credit : ",style = "font-family: 'times'; font-size: 19pt"),strong(textOutput("total_credit"),style = "font-family: 'times'; font-size: 19pt"),br(),
                strong("Total Debit : ",style = "font-family: 'times'; font-size: 19pt"),strong(textOutput("total_debit"),style = "font-family: 'times'; font-size: 19pt"),br(),
                strong("Average Balance : ",style = "font-family: 'times'; font-size: 19pt"),strong(textOutput("avg_balance"),style = "font-family: 'times'; font-size: 19pt"),br()
                
              )
              
      )
    )
  )
)
