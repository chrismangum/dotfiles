$CISCO_HOME = "C:\Users\chris\Cisco\"

Set-Alias l ls

Function cdc {
    cd $CISCO_HOME
}

Function cdsa {
    cd ($CISCO_HOME + "ApolloSupportAutomation")
}

Function cdhu {
    cd ($CISCO_HOME + "ApolloHubUser")
}

Function cdssa {
    cd ($CISCO_HOME + "ApolloSAStandalone")
}

Function cdsst {
    cd ($CISCO_HOME + "ApolloSAStandalone\build\standalone\staging")
}

Function gch {
    git checkout
}

Function gd {
    git diff
}

Function gdc {
    git diff --cached
}

Function gf {
    git fetch
    git status
}

Function gpl {
    git pull
}

Function gst {
    git status
}

Function snw {
    cdsst
    nw
}
