class SubmissionsController < ApplicationController
  def show
    render json: Submission.find_by!(token: params[:token]), base64_encoded: params[:base64_encoded] == "true"
  end

  def create
    submission = Submission.new(submission_params)

    if submission.save
      IsolateJob.perform_later(submission)
      render json: submission, status: :created, fields: [:token]
    else
      render json: submission.errors, status: :unprocessable_entity
    end
  end

  private

  def submission_params
    submission_params = params.permit(
      :source_code,
      :language_id,
      :number_of_runs,
      :input,
      :expected_output,
      :cpu_time_limit,
      :cpu_extra_time,
      :wall_time_limit,
      :memory_limit,
      :stack_limit,
      :max_processes_and_or_threads,
      :enable_per_process_and_thread_time_limit,
      :enable_per_process_and_thread_memory_limit,
      :max_file_size
    )

    params[:base64_encoded] == "true" ? decode_params(submission_params) : submission_params
  end

  def decode_params(params)
    params[:source_code] = Base64.decode64(params[:source_code]) if params[:source_code]
    params[:input] = Base64.decode64(params[:input]) if params[:input]
    params[:expected_output] = Base64.decode64(params[:expected_output]) if params[:expected_output]
    params
  end
end
