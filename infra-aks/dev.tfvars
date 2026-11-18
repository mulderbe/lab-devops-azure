# dev.tfvars — valores del stack AKS en dev. Sin secretos: se sube al repo.

entorno          = "dev"
admin_object_id  = "de58ff3b-59c2-49c6-83e8-a5987c55f24a" # el mismo de infra/dev.tfvars
key_vault_nombre = "kv-lab-dev-33ok"                      # CAMBIA: el tuyo (Paso 2.1)
node_size        = "Standard_D2as_v4"                     # el que confirmaste en el Paso 0
