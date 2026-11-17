MERGE `{{params.project_name}}.semantics_central.FinancingLedgerEntries` final
USING (
{{range_query}}
) staging
ON final.ledger_entry_id = staging.ledger_entry_id
WHEN MATCHED THEN
UPDATE SET
final.ledger_entry_id = staging.ledger_entry_id,
final.loan_id = staging.loan_id,
final.item = staging.item,
final.amount = staging.amount,
final.amount_usd = staging.amount_usd,
final.type = staging.type,
final.date = staging.date,
final.reference_id = staging.reference_id,
final.purpose = staging.purpose,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.created_by_name = staging.created_by_name,
final.created_by_id = staging.created_by_id,
final.updated_by_name = staging.updated_by_name,
final.updated_by_id = staging.updated_by_id,
final.deleted_by_name = staging.deleted_by_name,
final.deleted_by_id = staging.deleted_by_id,
final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
ledger_entry_id,
loan_id,
item,
amount,
amount_usd,
type,
date,
reference_id,
purpose,
created_at,
updated_at,
deleted_at,
created_by_name,
created_by_id,
updated_by_name,
updated_by_id,
deleted_by_name,
deleted_by_id,
country_id
) VALUES (
staging.ledger_entry_id,
staging.loan_id,
staging.item,
staging.amount,
staging.amount_usd,
staging.type,
staging.date,
staging.reference_id,
staging.purpose,
staging.created_at,
staging.updated_at,
staging.deleted_at,
staging.created_by_name,
staging.created_by_id,
staging.updated_by_name,
staging.updated_by_id,
staging.deleted_by_name,
staging.deleted_by_id,
staging.country_id
)