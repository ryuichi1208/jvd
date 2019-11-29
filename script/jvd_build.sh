LF=$(printf '\\\012_')
LF=${LF%_}
TAB=$'\t'

if [ -n "$_PASSWORD" ]; then
    echo "Enable Auth"
    # mv /fluentd/etc/conf.d/baas.conf /tmp/baas.conf
    cat /tmp/baas.conf \
        | sed "s/#  user/  user/" \
        | sed "s/#  password/  password/" \
        > /fluentd/etc/conf.d/baas.conf

    echo "Run create_user.rb"
    envsubst < /fluentd/create_user.template.rb > /tmp/create_user.rb
    ruby /tmp/create_user.rb
fi


