import json

def main(request):
    """
    HTTP Cloud Function.

    Args:
        request (google.cloud.functions_v1.types.HttpRequest): The HTTP request object.

    Returns:
        The HTTP response as a JSON string.
    """
    # Parse request arguments
    request_json = request.get_json(silent=True)
    request_args = request.args

    # Check for a "name" query parameter
    name = request_args.get('name', 'Glory')

    # Create a response message
    message = f"Hello, {name}!"

    # Return the response as a JSON object
    return json.dumps({"message": message})

