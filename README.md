# veracode-integration-example
An example on how kosli can integrate with veracode and Github.


# Simulated project

The project has two applications `frontend` and `backend`. The
two applications are in the same git repository, but are 
updated and released independently.

The "source code" for the two applications are the two files
```
apps/backend/backend-content.txt
apps/frontend/frontend-content.txt
```
To simulate a change of the software in an application just
increase the `counter=xx` number in the file.

There is a CI-pipeline build step for the 
[backend](https://github.com/kosli-dev/veracode-integration-example/actions/workflows/build-backend.yml)
and one for the
[frontend](https://github.com/kosli-dev/veracode-integration-example/actions/workflows/build-frontend.yml).
The CI-pipeline are only triggerd on changes to that particular application.

There are no real servers in this demo. We use some git tags to indicate what software is
running on which server:
- running-staging-backend
- running-staging-frontend
- running-prod-backend
- running-prod-frontend

For development, we use the latest version checked in on `main`

There are three GitHub actions that simulate the reporting of snapshots. 
- Report development snapshot
- Report staging snapshot
- Report prod snapshot
They trigger automatically once an hour, but can also be triggered manually.

There is a 
[kosli-setup](https://github.com/kosli-dev/veracode-integration-example/actions/workflows/setup-kosli.yml)
CI-pipeline to create all flows, environments, custom attestation types and policies.


# Software Process

The software process works like this:
- When an application is updated and build we must perform a veracode scan.
- Depending on the Severity and the GOB (Grace of Business) the issue mest be fixed within a given
number of days.
- A failure in the veracode scan does not prevent a deployment to staging or production.
- A job will run periodically to check if there are any outstanding veracode issues and inform developers.
- Good flow (fixed during grace period)
  - Developers fixes issue and the veracode scan issue is cleared (process marked as compliant)
- Bad flow (no fix when grace period expires)
  - Managers are informed that veracode issues has not been fixed.
  - Developer fixes issue after the grace period (process marked as non-compliant)

