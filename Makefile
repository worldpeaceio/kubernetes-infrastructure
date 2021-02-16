PROJECTS := ipfs_dev

.PHONY: lint
lint:
	terraform fmt

.PHONY: generate-name
generate-name:
	cd cluster_name_generator; \
		cargo run

.PHONY: deploy
deploy: $(addprefix deploy-,$(PROJECTS))

.PHONY: deploy-%
deploy-%:
	cd terraform/clusters/$*; \
		terraform init; \
		terraform apply

.PHONY: destroy-%
destroy-%:
	cd terraform/clusters/$*; \
		terraform init; \
		terraform destroy
