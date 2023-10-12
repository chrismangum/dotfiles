#k8s
alias k="kubectl"
alias kcreate="k create -f"
alias kdel="k delete"
alias kdesc="k describe"
alias kexec="k exec -ti"
alias kget="k get"
alias klogs="k logs -f"

alias kdep="kget deployments"
alias kpods="kget pods -o wide"
alias krc="kget replicationcontroller"
alias ksec="kget secrets"
alias ksv="kget services"
alias kwpods="watch kubectl get pods -o wide"

function kcontext() {
	kubectl config view | grep current-context: | awk 'NF>1{print $NF}'
}

function knamespace() {
	kubectl config view | grep -A 1 "cluster: $1" | awk 'FNR == 2 {print $2}'
}

function kcon() {
	local context=$(kcontext)
	local ns=$(knamespace $context)
	echo "[${context}|${ns}]"
}

function kcl() {
	if [ -z "$1" ]; then
		echo "specify a cluster"
		return 1
	fi
	kubectl config use-context $1
	kcon
}

function kns() {
	if [ -z "$1" ]; then
		echo "specify a namespace"
		return 1
	fi
	kubectl config set-context $(kcontext) --namespace=$1
	kcon
}

function kash() {
	kexec $1 -- /bin/ash
}

function kbash() {
	kexec $1 -- /bin/bash
}

function kdebug() {
	kubectl exec $1 -- kill -usr1 1;
	kubectl port-forward $1 9229:9229;
}
