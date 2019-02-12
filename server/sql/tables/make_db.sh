# Order matters!
cat db.sql \
    company.sql \
    invoice.sql \
    entry.sql \
    | mysql -u root -p

