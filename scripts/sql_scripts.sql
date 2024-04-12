-- POSTGRES SQL script for transactions table

-- UPDATE Function: captures the changes to specific columns into json object
CREATE OR REPLACE FUNCTION record_changed_columns()
RETURNS TRIGGER AS $$
DECLARE
    change_details JSONB;
BEGIN
    change_details = '{}'::JSONB;

    -- Check amount column for changes
    IF NEW.amount IS DISTINCT FROM OLD.amount THEN
        change_details = jsonb_insert(change_details, '{amount}', jsonb_build_object('old', OLD.amount, 'new', NEW.amount));
    END IF;

    -- Add user and timestamp
    change_details = change_details || jsonb_build_object('modified_by', current_user, 'modified_at', now());

    -- Update the change_info column
    NEW.change_info = change_details;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- UPDATE Trigger
CREATE TRIGGER trigger_record_user_update
BEFORE UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION record_changed_columns();