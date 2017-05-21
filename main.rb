uniq_path=`echo $PATH`.split(':').uniq.join(':')
`export PATH=#{uniq_path}`