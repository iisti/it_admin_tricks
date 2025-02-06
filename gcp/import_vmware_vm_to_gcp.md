# Instructions how to import a VMware VM to GCP
* ESXi version: 6.7 U3
* VM: Windows Server 2012 R2
  * Running SQL Express and a software using it.
  * Critical VM, but doesn't need run all the time.
* Source: https://cloud.google.com/compute/docs/import/importing-virtual-disks

# Pre-check
* Check with precheck tool that there shouldn't be issues with importing the machine.
  * Run in PowerShell as administrator.
  * https://github.com/GoogleCloudPlatform/compute-image-tools/tree/master/cli_tools/import_precheck/

# Importing VMDK and creating a VM in GCP
* Followed these instructions https://googlecloudplatform.github.io/compute-image-tools/image-import.html

~~~
user@machine01:/mnt/c/02-vms$ gsutil cp -r vm-007-migrate/ gs://gcp-migration-storage
Copying file://vm-007-migrate/vm-007-migrate-aux.xml [Content-Type=application/xml]...
Copying file://vm-007-migrate/vm-007-migrate-flat.vmdk [Content-Type=application/octet-stream]...
==> NOTE: You are uploading one or more large file(s), which would run
significantly faster if you enable parallel composite uploads. This
feature can be enabled by editing the
"parallel_composite_upload_threshold" value in your .boto
configuration file. However, note that if you do this large files will
be uploaded as `composite objects
<https://cloud.google.com/storage/docs/composite-objects>`_,which
means that any user who downloads such objects will need to have a
compiled crcmod installed (see "gsutil help crcmod"). This is because
without a compiled crcmod, computing checksums on composite objects is
so slow that gsutil disables downloads of composite objects.

Copying file://vm-007-migrate/vm-007-migrate.nvram [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vm-007-migrate.vmdk [Content-Type=application/octet-stream]...
| [4 files][ 40.0 GiB/ 40.0 GiB]   14.8 MiB/s
==> NOTE: You are performing a sequence of gsutil operations that may
run significantly faster if you instead use gsutil -m cp ... Please
see the -m section under "gsutil help options" for further information
about when gsutil -m can be advantageous.

Copying file://vm-007-migrate/vm-007-migrate.vmsd [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vm-007-migrate.vmx [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vm-007-migrate.vmxf [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmware-10.log [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmware-11.log [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmware-12.log [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmware-13.log [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmware-8.log [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmware-9.log [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmware.log [Content-Type=application/octet-stream]...
Copying file://vm-007-migrate/vmx-vm-007-migrate-2361921457-2.vswp [Content-Type=application/octet-stream]...
- [15 files][ 40.1 GiB/ 40.1 GiB]   16.9 MiB/s
Operation completed over 15 objects/40.1 GiB.
user@machine01:/mnt/c/02-vms$ gcloud compute ssh daisy-control
No zone specified. Using zone [europe-north1-a] for instance: [daisy-control].
Warning: Permanently added 'compute.2815874741513951114' (ECDSA) to the list of known hosts.
Linux daisy-control 4.9.0-9-amd64 #1 SMP Debian 4.9.168-1+deb9u5 (2019-08-11) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
~~~

## Convert to GCP image
~~~
user@daisy-control:~$ daisy -var:source_disk_file=gs://gcp-migration-storage/vm-007-migrate/vm-007-migrate-flat.vmdk -var:image
_name=import-vm-007-migrate-20200613 /daisy/image_import/import_image.wf.json
[Daisy] Running workflow "import-image" (id=x1w03)
[import-image]: 2020-06-13T10:58:56Z Unable to send logs to the Cloud Logging service, not sending logs: rpc error: code = PermissionDenied desc = Request had insufficient authentication scopes.
[import-image]: 2020-06-13T10:58:56Z Validating workflow
[import-image]: 2020-06-13T10:58:56Z Validating step "import-disk"
[import-image.import-disk]: 2020-06-13T10:58:56Z Validating step "setup-disks"
[import-image.import-disk]: 2020-06-13T10:58:57Z Validating step "import-virtual-disk"
[import-image.import-disk]: 2020-06-13T10:58:58Z Validating step "wait-for-signal"
[import-image.import-disk]: 2020-06-13T10:58:58Z Validating step "cleanup"
[import-image]: 2020-06-13T10:58:58Z Validating step "create-image"
[import-image]: 2020-06-13T10:58:59Z Validating step "delete-disk"
[import-image]: 2020-06-13T10:58:59Z Validation Complete
[import-image]: 2020-06-13T10:58:59Z Workflow Project: project-for-migrating-vms
[import-image]: 2020-06-13T10:58:59Z Workflow Zone: europe-north1-a
[import-image]: 2020-06-13T10:58:59Z Workflow GCSPath: gs://project-for-migrating-vms-daisy-bkt
[import-image]: 2020-06-13T10:58:59Z Daisy scratch path: https://console.cloud.google.com/storage/browser/project-for-migrating-vms-daisy-bkt/daisy-import-image-20200613-10:58:56-x1w03
[import-image]: 2020-06-13T10:58:59Z Uploading sources
[import-image]: 2020-06-13T11:25:46Z Running workflow
[import-image]: 2020-06-13T11:25:46Z Running step "import-disk" (IncludeWorkflow)
[import-image.import-disk]: 2020-06-13T11:25:46Z Running step "setup-disks" (CreateDisks)
[import-image.import-disk.setup-disks]: 2020-06-13T11:25:46Z CreateDisks: Creating disk "disk-import-disk-scratch-x1w03".
[import-image.import-disk.setup-disks]: 2020-06-13T11:25:46Z CreateDisks: Creating disk "imported-disk-x1w03".
[import-image.import-disk.setup-disks]: 2020-06-13T11:25:46Z CreateDisks: Creating disk "disk-importer-import-image-import-disk-x1w03".
[import-image.import-disk]: 2020-06-13T11:25:48Z Step "setup-disks" (CreateDisks) successfully finished.
[import-image.import-disk]: 2020-06-13T11:25:48Z Running step "import-virtual-disk" (CreateInstances)
[import-image.import-disk.import-virtual-disk]: 2020-06-13T11:25:48Z CreateInstances: Creating instance "inst-importer-import-image-import-disk-x1w03".
[import-image.import-disk]: 2020-06-13T11:25:55Z Step "import-virtual-disk" (CreateInstances) successfully finished.
[import-image.import-disk]: 2020-06-13T11:25:55Z Running step "wait-for-signal" (WaitForInstancesSignal)
[import-image.import-disk.import-virtual-disk]: 2020-06-13T11:25:55Z CreateInstances: Streaming instance "inst-importer-import-image-import-disk-x1w03" serial port 1 output to https://storage.cloud.google.com/project-for-migrating-vms-daisy-bkt/daisy-import-image-20200613-10:58:56-x1w03/logs/inst-importer-import-image-import-disk-x1w03-serial-port1.log
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:25:55Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": watching serial port 1, SuccessMatch: "ImportSuccess:", FailureMatch: ["ImportFailed:" "WARNING Failed to download metadata script" "Worker instance terminated"] (this is not an error), StatusMatch: "Import:".
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:26:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Resizing disk-import-disk-scratch-x1w03 to 45GB in projects/81626132246/zones/europe-north1-a."
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:26:26Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Checking for /dev/sdb 45G"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:26:26Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: /dev/sdb is attached and ready."
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Copied image from gs://project-for-migrating-vms-daisy-bkt/daisy-import-image-20200613-10:58:56-x1w03/sources/source_disk_file to /daisy-scratch/source_disk_file:"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Importing /daisy-scratch/source_disk_file of size 40GB to imported-disk-x1w03 in projects/81626132246/zones/europe-north1-a."
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: <serial-output key:'target-size-gb' value:'40'>"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: <serial-output key:'source-size-gb' value:'40'>"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: <serial-output key:'import-file-format' value:'raw'>"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Resizing imported-disk-x1w03 to 40GB in projects/81626132246/zones/europe-north1-a.'"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:16Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Resizing imported-disk-x1w03 to 40GB in projects/81626132246/zones/europe-north1-a."
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:26Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Checking for /dev/sdc 40G'"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:26Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: Checking for /dev/sdc 40G"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:26Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: /dev/sdc is attached and ready.'"
[import-image.import-disk.wait-for-signal]: 2020-06-13T11:48:26Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": StatusMatch found: "Import: /dev/sdc is attached and ready."
[import-image.import-disk.wait-for-signal]: 2020-06-13T12:03:36Z WaitForInstancesSignal: Instance "inst-importer-import-image-import-disk-x1w03": SuccessMatch found "ImportSuccess: Finished import.'"
[import-image.import-disk]: 2020-06-13T12:03:36Z Step "wait-for-signal" (WaitForInstancesSignal) successfully finished.
[import-image.import-disk]: 2020-06-13T12:03:36Z Running step "cleanup" (DeleteResources)
[import-image.import-disk.cleanup]: 2020-06-13T12:03:36Z DeleteResources: Deleting instance "inst-importer".
[import-image.import-disk]: 2020-06-13T12:04:03Z Step "cleanup" (DeleteResources) successfully finished.
[import-image]: 2020-06-13T12:04:03Z Step "import-disk" (IncludeWorkflow) successfully finished.
[import-image]: 2020-06-13T12:04:03Z Running step "create-image" (CreateImages)
[import-image.create-image]: 2020-06-13T12:04:03Z CreateImages: Creating image "import-vm-007-migrate-20200613".
[import-image]: 2020-06-13T12:07:47Z Step "create-image" (CreateImages) successfully finished.
[import-image]: 2020-06-13T12:07:47Z Running step "delete-disk" (DeleteResources)
[import-image.delete-disk]: 2020-06-13T12:07:47Z DeleteResources: Deleting disk "imported-disk-x1w03".
[import-image]: 2020-06-13T12:07:48Z Step "delete-disk" (DeleteResources) successfully finished.
[import-image]: 2020-06-13T12:07:48Z Serial-output value -> target-size-gb:40
[import-image]: 2020-06-13T12:07:48Z Serial-output value -> source-size-gb:40
[import-image]: 2020-06-13T12:07:48Z Serial-output value -> import-file-format:raw
[import-image]: 2020-06-13T12:07:48Z Workflow "import-image" cleaning up (this may take up to 2 minutes).
[import-image]: 2020-06-13T12:07:50Z Workflow "import-image" finished cleanup.
[Daisy] Workflow "import-image" finished
[Daisy] All workflows completed successfully.
~~~
## Create bootable image
~~~
user@daisy-control:~$ daisy -var:source_image=projects/project-for-migrating-vms/global/images/import-vm-007-migrate-20200613 -var:translate_workflow=/daisy/image_import/windows/translate_windows_2012_r2.wf.json -var:image_name=vm-007-migrate-image /daisy/image_import/import_from_image.wf.json
[Daisy] Running workflow "import-from-image" (id=rqs1v)
[import-from-image]: 2020-06-13T12:17:49Z Unable to send logs to the Cloud Logging service, not sending logs: rpc error: code = PermissionDenied desc = Request had insufficient authentication scopes.
[import-from-image]: 2020-06-13T12:17:49Z Validating workflow
[import-from-image]: 2020-06-13T12:17:49Z Validating step "create-disk"
[import-from-image]: 2020-06-13T12:17:50Z Validating step "translate-disk"
[import-from-image.translate-disk]: 2020-06-13T12:17:50Z Validating step "translate-image"
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:17:50Z Validating step "setup-disk"
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:17:51Z Validating step "bootstrap"
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:17:51Z Validating step "wait-for-bootstrap"
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:17:51Z Validating step "delete-bootstrap"
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:17:51Z Validating step "translate"
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:17:51Z Validating step "wait-for-translate"
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:17:51Z Validating step "delete-inst-translate"
[import-from-image.translate-disk]: 2020-06-13T12:17:51Z Validating step "create-image"
[import-from-image]: 2020-06-13T12:17:52Z Validation Complete
[import-from-image]: 2020-06-13T12:17:52Z Workflow Project: project-for-migrating-vms
[import-from-image]: 2020-06-13T12:17:52Z Workflow Zone: europe-north1-a
[import-from-image]: 2020-06-13T12:17:52Z Workflow GCSPath: gs://project-for-migrating-vms-daisy-bkt
[import-from-image]: 2020-06-13T12:17:52Z Daisy scratch path: https://console.cloud.google.com/storage/browser/project-for-migrating-vms-daisy-bkt/daisy-import-from-image-20200613-12:17:49-rqs1v
[import-from-image]: 2020-06-13T12:17:52Z Uploading sources
[import-from-image]: 2020-06-13T12:18:00Z Running workflow
[import-from-image]: 2020-06-13T12:18:00Z Running step "create-disk" (CreateDisks)
[import-from-image.create-disk]: 2020-06-13T12:18:00Z CreateDisks: Creating disk "imported-disk-rqs1v".
[import-from-image]: 2020-06-13T12:19:18Z Step "create-disk" (CreateDisks) successfully finished.
[import-from-image]: 2020-06-13T12:19:18Z Running step "translate-disk" (IncludeWorkflow)
[import-from-image.translate-disk]: 2020-06-13T12:19:18Z Running step "translate-image" (IncludeWorkflow)
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:19:18Z Running step "setup-disk" (CreateDisks)
[import-from-image.translate-disk.translate-image.setup-disk]: 2020-06-13T12:19:18Z CreateDisks: Creating disk "disk-bootstrap-import-from-image-translate-disk-translat-rqs1v".
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:22:52Z Step "setup-disk" (CreateDisks) successfully finished.
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:22:52Z Running step "bootstrap" (CreateInstances)
[import-from-image.translate-disk.translate-image.bootstrap]: 2020-06-13T12:22:52Z CreateInstances: Creating instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v".
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:23:29Z Step "bootstrap" (CreateInstances) successfully finished.
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:23:29Z Running step "wait-for-bootstrap" (WaitForInstancesSignal)
[import-from-image.translate-disk.translate-image.bootstrap]: 2020-06-13T12:23:29Z CreateInstances: Streaming instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v" serial port 1 output to https://storage.cloud.google.com/project-for-migrating-vms-daisy-bkt/daisy-import-from-image-20200613-12:17:49-rqs1v/logs/inst-bootstrap-import-from-image-translate-disk-translat-rqs1v-serial-port1.log
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:23:29Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": watching serial port 1, SuccessMatch: "Translate bootstrap complete", FailureMatch: ["TranslateFailed:"] (this is not an error), StatusMatch: "TranslateBootstrap:".
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:25:00Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "TranslateBootstrap: Beginning translation bootstrap powershell script."
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:25:10Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "TranslateBootstrap: Pulling components."
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:25:20Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "TranslateBootstrap: Pulling drivers."
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:25:20Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "TranslateBootstrap: Slipstreaming drivers."
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:25:30Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "TranslateBootstrap: Setting up script runner."
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:25:30Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "TranslateBootstrap: Rewriting boot files."
[import-from-image.translate-disk.translate-image.wait-for-bootstrap]: 2020-06-13T12:25:30Z WaitForInstancesSignal: Instance "inst-bootstrap-import-from-image-translate-disk-translat-rqs1v": SuccessMatch found "Translate bootstrap complete."
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:25:30Z Step "wait-for-bootstrap" (WaitForInstancesSignal) successfully finished.
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:25:30Z Running step "delete-bootstrap" (DeleteResources)
[import-from-image.translate-disk.translate-image.delete-bootstrap]: 2020-06-13T12:25:30Z DeleteResources: Deleting instance "inst-bootstrap".
[import-from-image.translate-disk.translate-image.delete-bootstrap]: 2020-06-13T12:27:57Z DeleteResources: Deleting disk "disk-bootstrap".
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:27:59Z Step "delete-bootstrap" (DeleteResources) successfully finished.
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:27:59Z Running step "translate" (CreateInstances)
[import-from-image.translate-disk.translate-image.translate]: 2020-06-13T12:27:59Z CreateInstances: Creating instance "inst-translate-import-from-image-translate-disk-translat-rqs1v".
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:28:06Z Step "translate" (CreateInstances) successfully finished.
[import-from-image.translate-disk.translate-image.translate]: 2020-06-13T12:28:06Z CreateInstances: Streaming instance "inst-translate-import-from-image-translate-disk-translat-rqs1v" serial port 1 output to https://storage.cloud.google.com/project-for-migrating-vms-daisy-bkt/daisy-import-from-image-20200613-12:17:49-rqs1v/logs/inst-translate-import-from-image-translate-disk-translat-rqs1v-serial-port1.log
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:28:06Z Running step "wait-for-translate" (WaitForInstancesSignal)
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:28:06Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": watching serial port 1, SuccessMatch: "Translate complete", FailureMatch: ["TranslateFailed:"] (this is not an error), StatusMatch: "Translate:".
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:28:06Z WaitForInstancesSignal: Waiting for instance "inst-translate-import-from-image-translate-disk-translat-rqs1v" to stop.
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:29:47Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Starting image translate...\""
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:30:17Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Beginning translate PowerShell script."
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:30:17Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Found VMWare Tools installed, removing..."
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:36:27Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Beginning translate PowerShell script."
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:36:27Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Setting instance properties."
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:41:27Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Configuring network."
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:41:37Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Setting up NTP."
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:41:47Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Installing GCE packages..."
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:42:07Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": StatusMatch found: "Translate: Setting up KMS activation"
[import-from-image.translate-disk.translate-image.wait-for-translate]: 2020-06-13T12:42:07Z WaitForInstancesSignal: Instance "inst-translate-import-from-image-translate-disk-translat-rqs1v": SuccessMatch found "Translate complete."
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:42:07Z Step "wait-for-translate" (WaitForInstancesSignal) successfully finished.
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:42:07Z Running step "delete-inst-translate" (DeleteResources)
[import-from-image.translate-disk.translate-image.delete-inst-translate]: 2020-06-13T12:42:07Z DeleteResources: Deleting instance "inst-translate".
[import-from-image.translate-disk.translate-image]: 2020-06-13T12:42:44Z Step "delete-inst-translate" (DeleteResources) successfully finished.
[import-from-image.translate-disk]: 2020-06-13T12:42:44Z Step "translate-image" (IncludeWorkflow) successfully finished.
[import-from-image.translate-disk]: 2020-06-13T12:42:44Z Running step "create-image" (CreateImages)
[import-from-image.translate-disk.create-image]: 2020-06-13T12:42:44Z CreateImages: Creating image "vm-007-migrate-image".
[import-from-image.translate-disk]: 2020-06-13T12:45:45Z Step "create-image" (CreateImages) successfully finished.
[import-from-image]: 2020-06-13T12:45:45Z Step "translate-disk" (IncludeWorkflow) successfully finished.
[import-from-image]: 2020-06-13T12:45:45Z Workflow "import-from-image" cleaning up (this may take up to 2 minutes).
[import-from-image]: 2020-06-13T12:45:47Z Workflow "import-from-image" finished cleanup.
[Daisy] Workflow "import-from-image" finished
[Daisy] All workflows completed successfully.
~~~

## Create VM with the newly created image
* If there's an Microsoft Active Directory in the GCP, set "static" DHCP IP and change DNS IP from the VM OS to point the AD DC.

## Some tips
~~~
# List buckets
gsutil ls

# List bucket contents, use -r if all files should be listed.
gsutil ls gs://BUCKET_NAME/**
~~~
