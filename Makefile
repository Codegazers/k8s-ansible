update:
	@git pull
destroy:
	@vagrant destroy -f || true
	@rm -rf tmp_deploying_stage

create:
	@vagrant up -d

recreate:
	@make destroy
	@make create

stop:
	@VBoxManage controlvm k8s-node3 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm k8s-node2 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm k8s-node1 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm k8s-master1 acpipowerbutton 2>/dev/null || true

start:
	@VBoxManage startvm k8s-master1 --type headless 2>/dev/null || true
	@sleep 10
	@VBoxManage startvm k8s-node1 --type headless 2>/dev/null || true
	@VBoxManage startvm k8s-node2 --type headless 2>/dev/null || true
	@VBoxManage startvm k8s-node3 --type headless 2>/dev/null || true

status:
	@VBoxManage list runningvms
