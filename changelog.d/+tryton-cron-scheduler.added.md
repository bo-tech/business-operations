Tryton can run `trytond-cron`, the scheduler that executes `ir.cron`
work such as reminders and clean-up jobs. The chart deploys it as a
container in the trytond Pod, and it stays off until a cluster names
the databases it should process
