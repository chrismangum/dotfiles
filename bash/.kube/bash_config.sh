#k8s
alias k="kubectl"
alias kpods="k get pods -o wide"
alias kservices="k get services"
# alias kd="k get deployments"
# alias krc="k get replicationcontroller"
# alias ks="k get secrets"
alias klogs="k logs -f"
# alias ktail="kubetail"
# alias kexec="k exec -it"
# alias kdesc="k describe"

# alias kwatchpods="watch kubectl get pods"

function kcontext() {
	local context=$(k config view | grep current-context: | awk 'NF>1{print $NF}')
	local ns=$(k config view | grep -A 1 "cluster: $context" | awk 'FNR == 2 {print $2}')
	echo "[${context}|${ns}]"
}

function krestart() {
	k get pod $1 -o yaml | kubectl replace --force -f -
}

function kshell() {
	k exec -it $1 /bin/ash
}

function kswitch() {
	local context=$(k config view | grep current-context: | awk 'NF>1{print $NF}')
	k config set-context $context --namespace=$1
	kcontext
}

function kdebug() {
	k exec $1 -- kill -usr1 1;
	k port-forward $1 9229:9229;
}

