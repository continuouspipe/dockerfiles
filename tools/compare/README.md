# Comparison Tool

A tool to compare the :latest and :stable tags of each of the docker images, and tag
the :latest image as :stable if the diff is agreeable.

## Usage

From the root directory of this repository:
```bash
bash tools/compare/pull_and_compare.sh LIST OF SERVICES
```
where the service names are listed in `docker-compose.yml`.

For example:
```bash
bash tools/compare/pull_and_compare.sh spryker_php70_nginx spryker_php71_nginx
```
