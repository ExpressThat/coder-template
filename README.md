# Coder Desktop Template

This repository contains a Coder Docker template under `template/` and a GitHub Actions workflow for building the desktop image and deploying the template.

## GitHub Actions Deployment

The workflow at `.github/workflows/deploy-template.yml` runs on pushes to `main` or `master`, and can also be run manually. It:

- Builds `template/Dockerfile`.
- Pushes `rosssearle/ubuntu-desktop:<short-sha>` and `rosssearle/ubuntu-desktop:latest` to Docker Hub.
- Rewrites `template/main.tf` during CI so the template points at the newly pushed SHA-tagged image.
- Pushes the template to your Coder instance with `coder templates push`.

The Coder URL is configured directly in the workflow as:

```text
CODER_URL=https://coder.rosssearle.com
```

Configure these GitHub repository secrets:

- `DOCKERHUB_TOKEN`: Docker Hub token with write access to `rosssearle/ubuntu-desktop`.
- `CODER_ACCESS_TOKEN`: A Coder token with permission to push templates.

Manual runs can override the image tag and Coder template name. The default template name is `docker-desktop`.

## Template

See `template/README.md` for local template usage and image details.
