provider "databricks" {
  host                        = "https://${azurerm_databricks_workspace.study.workspace_url}"
  azure_workspace_resource_id = azurerm_databricks_workspace.study.id
  auth_type                   = "azure-cli"
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  ml                = false

  depends_on = [
    azurerm_databricks_workspace.study
  ]
}

data "databricks_node_type" "smallest" {
  local_disk = true

  depends_on = [
    azurerm_databricks_workspace.study
  ]
}

resource "databricks_notebook" "demo" {
  path     = "/Shared/study-demo-notebook"
  language = "PYTHON"

  content_base64 = base64encode(<<EOT
print("Hello from low-cost single-node Databricks job cluster")
EOT
  )

  depends_on = [
    azurerm_databricks_workspace.study
  ]
}

resource "databricks_job" "study_job" {
  name = "study-low-cost-single-node-job"

  task {
    task_key = "demo_task"

    notebook_task {
      notebook_path = databricks_notebook.demo.path
    }

    new_cluster {
      spark_version = data.databricks_spark_version.latest_lts.id
      node_type_id  = data.databricks_node_type.smallest.id

      num_workers = 0

      spark_conf = {
        "spark.databricks.cluster.profile" = "singleNode"
        "spark.master"                     = "local[*]"
      }

      custom_tags = {
        "ResourceClass" = "SingleNode"
      }

      data_security_mode = "SINGLE_USER"

      azure_attributes {
        availability = "SPOT_WITH_FALLBACK_AZURE"
      }
    }
  }

  depends_on = [
    databricks_notebook.demo
  ]
}