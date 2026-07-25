# dev-platform-sample-api

Aplicación de ejemplo **real** de la plataforma de desarrollo (`dev-platform`).
Instancia del scaffold `templates/nestjs-api` conforme a `PLATFORM.md`.

Existe por una razón concreta y no decorativa: **ArgoCD necesita clonar un repo
de verdad**. Los scaffolds viven dentro del repo de plataforma, que es local y
sin remoto; un motor GitOps no puede reconciliar contra eso. Este repo es la
primera pieza que demuestra el lazo entero.

| Entorno | Namespace | Rama | Gobierna | URL |
|---|---|---|---|---|
| `local` | `local` | *(el working tree)* | Skaffold | http://sample-api.local.localtest.me |
| `pre` | `pre` | `release` | ArgoCD | http://sample-api.pre.localtest.me |
| `pro` | `pro` | `main` | ArgoCD | http://sample-api.pro.localtest.me |

- **Iterar**: `skaffold dev` (rango de puertos `19030–19039`).
- **Desplegar en `pre`**: push a `release`. CI construye, publica y escribe el
  tag en `k8s/overlays/pre/kustomization.yaml`; ArgoCD lo recoge.
- **Promocionar a `pro`**: merge `release` → `main`. No se toca el cluster.

No hay ningún paso manual sobre el cluster en `pre` ni en `pro`. Si hace falta
uno, es un fallo de diseño, no una excepción.

## Por qué los tres overlays existen siempre

El ApplicationSet de la plataforma genera una Application por cada directorio
de `k8s/overlays/` (excepto `local`). Si `k8s/overlays/pro/` no existiera, la
aplicación **no se desplegaría en `pro` y nadie vería ningún error**. Por eso
los tres están, y un proyecto que de verdad no quisiera `pro` lo dejaría
vacío-explícito, con un `kustomization.yaml` sin recursos y el motivo escrito.
