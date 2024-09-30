resource "helm_release" "ollama_ui" {
  name             = "open-webui"
  chart            = "https://helm.openwebui.com/"
  namespace        = "ollama-ui"
  wait             = true

  # Force resource to ignore existing cache by specifying dependency on namespace creation
  depends_on = [kubernetes_namespace.ollama_ui]
}

resource "kubernetes_namespace" "ollama_ui" {
  metadata {
    name = "ollama-ui"
  }
}
