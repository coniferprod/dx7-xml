import sys
import xmlschema

try:
    # Initializing the object automatically triggers an internal meta-schema validation
    schema = xmlschema.XMLSchema(sys.argv[1])
    print("valid")
except xmlschema.validators.exceptions.XMLSchemaParseError as e:
    print(f"{e.lineno}: {e.message}")
