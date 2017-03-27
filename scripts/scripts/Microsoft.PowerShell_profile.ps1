$CISCO_HOME = "C:\Users\chris\Cisco\"

Set-Alias l ls

Function cdc {
    cd $CISCO_HOME
}

Function cdsa {
    cd ($CISCO_HOME + "SupportAutomation")
}

Function cdhu {
    cd ($CISCO_HOME + "HubUser")
}

Function cdssa {
    cd ($CISCO_HOME + "CLIAnalyzer")
}

Function cdsst {
    cd ($CISCO_HOME + "CLIAnalyzer\build\standalone\staging")
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
