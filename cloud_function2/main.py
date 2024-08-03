def main(request):
    """
    HTTP Cloud Function.
    
    Args:
        request (google.cloud.functions_v1.types.HttpRequest): The HTTP request object.
    
    Returns:
        A plain text response indicating the success of the function.
    """
    # Check for a "status" query parameter
    status = request.args.get('status', 'unknown')
    
    # Create a response message
    response_message = f"Function received status: {status}"
    
    # Return the response as plain text
    return response_message
    #Succesfully request received 
