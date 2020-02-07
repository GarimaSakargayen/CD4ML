resource "local_file" "eks_config" {
  content  = module.eks_cluster.kubeconfig
  filename = "kubeconfig"
}

resource "null_resource" "makeKubeConfig" {
  triggers = {
    template = local_file.eks_config.content
  }
  provisioner "local-exec" {
    command = "cp -f kubeconfig $HOME/.kube/config-${module.workspaces.env}"
  }
}

resource "local_file" "config_map_aws_auth" {
  content  = module.eks_cluster.config_map_aws_auth
  filename = "config_map_aws_auth.yml"
}

resource "null_resource" "ApplyAWSCredentials" {
  depends_on = [
    null_resource.makeKubeConfig,
    module.eks_worker,
  ]
  triggers = {
    template = local_file.config_map_aws_auth.content
  }
  provisioner "local-exec" {
    command = <<EOT
                
                # Source profile for ks and argocd commands if needed
                . ~/.profile

                # Set KUBECONFIG to current environment
                export KUBECONFIG=$HOME/.kube/config-${module.workspaces.env}
		echo "KUBECONFIG: $KUBECONFIG"
                kubectl config set-context aws-${module.workspaces.env}

                # Apply aws authentication and GPU driver to cluser (if needed)
                kubectl apply -f $HOME/CD4ML/terraform/config_map_aws_auth.yml
		sleep 60
                # kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.10/nvidia-device-plugin.yml

                # Create namespaces for kubeflow and model
                # kubectl create namespace kubeflow
		# kubectl create namespace sandbox

                # Create kubectl secrets for S3 connection
                # kubectl create secret generic aws-creds -n mnist --from-literal=awsAccessKeyID=${var.access_key}   --from-literal=awsSecretAccessKey=${var.secret_key}


                # If workspace is train
                if test "${module.workspaces.env}" = 'train'; then
			export PATH=$PATH:"/home/vagrant/bin"
			echo "PATH: $PATH"
			export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_aws.0.7.1.yaml"
			echo "CONFIG_URI: $CONFIG_URI"
			export AWS_CLUSTER_NAME="${module.workspaces.aws_cluster_name}"
			echo "AWS_CLUSTER_NAME: $AWS_CLUSTER_NAME"
			export KF_NAME=$AWS_CLUSTER_NAME
			echo "KF_NAME $KF_NAME"
			export BASE_DIR="/home/vagrant/kubeflow_base"
			export KF_DIR=$BASE_DIR/$KF_NAME
			echo "KF_DIR: $KF_DIR"
			rm -rf $KF_DIR 
			pwd
			mkdir -p $KF_DIR
			cd $KF_DIR
			kfctl build -V -f $CONFIG_URI
			export CONFIG_FILE="$KF_DIR/kfctl_aws.0.7.1.yaml"
			echo "CONFIG_FILE: $CONFIG_FILE"
			
			sed -i'.bak' -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' $CONFIG_FILE
			# replace role name
			export NODE_ROLE="${module.iam.aws_eks_nodes_role_name}"
			echo "NODE_ROLE: $NODE_ROLE"
			sed -i'.bak2' '/roles:/{n;s/.*/      - '"$NODE_ROLE"'/}' $CONFIG_FILE
			sed -i'.bak1' 's/control_plane_logging: .*/control_plane_logging: true/' $KF_DIR/aws_config/cluster_features.yaml
			sed -i'.bak2' 's/worker_node_group_logging: .*/worker_node_group_logging: true/' $KF_DIR/aws_config/cluster_features.yaml
			cd $KF_DIR
			rm -rf kustomize/  # Remove kustomize folder and regenerate files after customization
			echo "check kustomize"
			kfctl apply -V -f $CONFIG_FILE
			sleep 30
			kubectl get ingress -n istio-system
			export PROMETHEUS_SETUP="/home/vagrant/kube-prometheus/manifests/setup"
			export PROMETHEUS="/home/vagrant/kube-prometheus/manifests"

                 	kubectl create -f $PROMETHEUS_SETUP
			until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
			kubectl create -f $PROMETHEUS
			kubectl -n kubeflow get all
			kubectl get ingress -n istio-system

                fi
                
                # If workspace is prod
                if test "${module.workspaces.env}" = 'prod'; then
			# place holder for deploying prod eks


                fi

                # Deploy kubeflow to training and prod environments
                ## ks apply kubeflow-${module.workspaces.env}
                
              
EOT

  }
}

