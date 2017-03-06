
#k8s
alias k="kubectl"
alias kpods="k get pods -o wide"
alias kservices="k get services"
alias kd="k get deployments"
alias krc="k get replicationcontroller"
alias ks="k get secrets"
alias klogs="k logs -f"
alias ktail="kubetail"
alias kexec="k exec -it"
alias kdesc="k describe"

alias kwatchpods="watch kubectl get pods"

kcontext() {
  context=$(k config view | grep current-context: | awk 'NF>1{print $NF}')
  ns=$(k config view | grep -A 1 "cluster: $context" | awk 'FNR == 2 {print $2}')
  echo "[${context}|${ns}]"
}

kcon() {
 k exec -it $1 /bin/$2
}

kswitch() {
 k config use-context $1
}

kns() {
 # 1: namespace
 # 2: context (dev / senna) defaults to dev

 context=$2
 if [[ -z $context ]] ; then
  context="dev"
 fi

 k config set-context $context --namespace=$1
}

kstats() {
 nodes=( $(k get nodes | awk 'FNR > 1 {print $1}') )
 for (( i=0; i<${#nodes[@]}; i++ )); do
  k describe node ${nodes[i]};
  #| sed -n -e '/Namespace/,$p'
 done
}
