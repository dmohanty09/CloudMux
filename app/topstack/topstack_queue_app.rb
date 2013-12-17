require 'sinatra'
require 'fog'

class TopStackQueueApp < ResourceApiBase

	before do
		if(params[:cred_id].nil? || ! Auth.validate(params[:cred_id],"Scalable Queue","action"))
        message = Error.new.extend(ErrorRepresenter)
        message.message = "Cannot access this service under current policy."
        halt [NOT_AUTHORIZED, message.to_json]
    else
        cloud_cred = get_creds(params[:cred_id])
        if cloud_cred.nil?
            halt [NOT_FOUND, "Credentials not found."]
        else
            begin
                # Find Monitor service endpoint
                endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"SQS"}).first
                halt [BAD_REQUEST] if endpoint.nil?
                fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
                fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
                @sqs = Fog::AWS::SQS.new(fog_options)
                halt [BAD_REQUEST] if @sqs.nil?
            rescue Fog::Errors::NotFound => error
                halt [NOT_FOUND, error.to_s]
            end
        end
    end
  end

	#
	# Queues
	#
  ##~ sapi = source2swagger.namespace("topstack_queue")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Queue"] = {:id => "Queue", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/queue/queues"
  ##~ a.description = "Manage Queue resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Queues (Topstack cloud)"
  ##~ op.nickname = "describe_queues"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for topics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of queues returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/queues' do
		filters = params[:filters]
		if(filters.nil?)
			list_response = @sqs.list_queues.body["QueueUrls"]
		else
			list_response = @sqs.list_queues(filters).body["QueueUrls"]
		end
		response = []
		list_response.each do |q|
			queue_url_split = q.split("/")
			if(queue_url_split.length > 0)
				#Queue name is last item in url path
				name = queue_url_split[queue_url_split.length - 1]
			else
				name = ""
			end
			queue = {"QueueUrl" => q, "QueueName" => name}
			#Even though a user can list all queues, they may not have access to get_queue_attributes
			begin
				attrs = @sqs.get_queue_attributes(q, "All").body["Attributes"]
            	queue.merge!(attrs)
            rescue
            	#Do Nothing
            	#This is incase they do not have permission, or deleted queue remains in list
            end
            response << queue
		end
		[OK, response.to_json]
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/queue/queues"
  ##~ a.description = "Manage Queue resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Queues (Topstack cloud)"
  ##~ op.nickname = "create_queues"
  ##~ sapi.models["CreateQueue"] = {:id => "CreateQueue", :properties => {:QueueName => {:type => "string"},:VisibilityTimeout => {:type => "string"},:MessageRetentionPeriod => {:type => "string"},:MaximumMessageSize => {:type => "string"},:DelaySeconds => {:type => "string"},:ReceiveMessageWaitTimeSeconds => {:type => "string"}}}  
  ##~ op.parameters.add :name => "queue", :description => "Queue to Create", :dataType => "CreateQueue", :allowMultiple => false, :required => false, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, queue created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/queues' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["queue"].nil?)
			[BAD_REQUEST]
		else
			begin
				queue = json_body["queue"]
				response = @sqs.create_queue(queue["QueueName"],{"VisibilityTimeout"=> queue["VisibilityTimeout"],
																"MessageRetentionPeriod"=> queue["MessageRetentionPeriod"],
																"MaximumMessageSize"=> queue["MaximumMessageSize"],
																"DelaySeconds"=> queue["DelaySeconds"],
																"ReceiveMessageWaitTimeSeconds"=> queue["ReceiveMessageWaitTimeSeconds"]})
				queue.delete("QueueName");
				queue.keys.each do |key|
        			@sqs.set_queue_attributes(response.body["QueueUrl"], key, queue[key])
   				end
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/queue/queues"
  ##~ a.description = "Manage Queue resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Queues (Topstack cloud)"
  ##~ op.nickname = "delete_queues"
  ##~ sapi.models["DeleteQueue"] = {:id => "DeleteQueue", :properties => {:QueueUrl => {:type => "string"}}}  
  ##~ op.parameters.add :name => "queue", :description => "Queue to Delete", :dataType => "DeleteQueue", :allowMultiple => false, :required => false, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, queue deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/queues' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["queue"].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @sqs.delete_queue(json_body["queue"]["QueueUrl"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
end
