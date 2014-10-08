class CancellationFormNormalizer
  include Sidekiq::Worker

  sidekiq_options queue: :cancellation_normalizer,
    retry: 5,
    backtrace: true

  def perform user_id
    user = User.find user_id
    form = ''

    if user.cancellation_form
      form = user.cancellation_form

      path = "#{form.path(:cut_here)}"

      orig_filename = path[path.rindex('/') + 1..-1]

      index = path.index('cut_here') - 1
      path = path[0..index]

      files = Dir.glob("#{path}*/*")

      files.each do |file|
        File.rename(file, file[0..file.rindex('/')] + orig_filename)
      end
    end
  end
end
