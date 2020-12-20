# JSONリクエストパラメーターキーをキャメルケースからスネークケースに変換する。
ActionDispatch::Request.parameter_parsers[:json] = lambda { |raw_post|
  data = ActiveSupport::JSON.decode(raw_post)

  # キャメルケースのパラメーターキーをスネークケースに変換する。
  if data.is_a?(Array)
    data.map { |item| item.deep_transform_keys!(&:underscore) }
  else
    data.deep_transform_keys!(&:underscore)
  end

  data
}
