require 'spec_helper'

describe VirtualHostServiceWorker::HaproxyVHostWriter do
  before do
    File.delete("#{APP_CONFIG['haproxy_cert_list']}")
  rescue Errno::ENOENT => _e
  end
  let(:haproxy_cert_list_content) do
    File.read("#{APP_CONFIG['haproxy_cert_list']}")
  end

  let :valid_payload do
    {
      'id' => 1,
      'ssl_certificate' =>
      "-----BEGIN CERTIFICATE-----\nMIID1DCCAbwCAQEwDQYJKoZIhvcNAQEFBQAwgYgxCzAJBgNVBAYTAkRFMREwDwYD\nVQQIEwhTYWFybGFuZDEVMBMGA1UEBxMMU2FhcmJydWVja2VuMQ0wCwYDVQQKEwRh\ndnRxMRAwDgYDVQQLEwdob3N0aW5nMQ0wCwYDVQQDEwRvbGxpMR8wHQYJKoZIhvcN\nAQkBFhBvd29sZkBhdmFydGVxLmRlMB4XDTEzMDYyNTA3NDg1MloXDTE0MDYyNTA3\nNDg1MlowWzELMAkGA1UEBhMCREUxEzARBgNVBAgTClNvbWUtU3RhdGUxCzAJBgNV\nBAcTAnNiMQwwCgYDVQQKEwNvcmcxDTALBgNVBAsTBHVuaXQxDTALBgNVBAMTBG5h\nbWUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAJhiuU8QqHPlk+HEpcu861BH\ngVDUTOkjcqTHmWBcOafykhfCUrLe6gU1NHgA1z2vixuX87RCEqHb99wwWurCEc79\nyc+9LG2Va6khuC+X8xEH9/W0qul7E8u1OhwQVtTAVkv2AXFvhsOfUM+PN6EDdp8d\n4Fg53M9DY1PfKk0mc27hAgMBAAEwDQYJKoZIhvcNAQEFBQADggIBABbt7WxEu6A+\n+Jszqm3j7UOT0JRcCb8QVjNQlejtpjpntQrRLUWl4YbCAtGTSLAIJ8x3zB8aOEQx\nsZQ7BcVQipNgr3P3wSzCdFPGaqe5IuXq0UypmHjr854G+Dt997CIuvH1g9Qylnck\npClpswMhltvnkcjPGEGiBtH5dXyVrRklXzSDHmX4vg5dv1GVLpEnq5XrvKypN/Hq\nzuWvyd6FUuXZ6BMlrfUoa4mZTxY3FGpcoqJugKAX5GOiNLz9sNpG4X9X37QnVPKE\n0BHdkJoyTuAgaEH+/3bYNrx+VvU1mvY+M6QPr2joLLDtTro1M1+oOMyXwK99e2lS\n3K0l6S546A2Po4Kw5txMz9ETId5N3cHo1hwwirGItLSFblNWitsLG56eW+sE+NoV\nqh4F1fYl6XPcRlqel5H29a8uQWN3jWsDDnsih5PCvEEPMAJ+E+vDTNBo4bGeKHw5\nmcnrksdX9+yqwtT5uev/7PXM6IdMTB+VxW6n0fiNa/nhMApDmHvVrxSSaht7QxiY\n9T/X2Hd8SgTZAjeTbgTqxvhyAh1Y24ti6yIvUj35oZUlg5teO6W9LQOSklHgy7MH\nnenMSGo4crCtBmTLWtqxhuizKD7OEEenXOUeGCDeDDGZOOgCcw9oVk5ZErhndTqR\n7BeVZ1Q+foNw3Yl5o46J5K5AvIulzMCP\n-----END CERTIFICATE-----",
      'ssl_ca_certificate' =>
      "-----BEGIN CERTIFICATE-----\n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\n-----END CERTIFICATE-----",
      'ssl_key' =>
      "-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQCYYrlPEKhz5ZPhxKXLvOtQR4FQ1EzpI3Kkx5lgXDmn8pIXwlKy\n3uoFNTR4ANc9r4sbl/O0QhKh2/fcMFrqwhHO/cnPvSxtlWupIbgvl/MRB/f1tKrp\nexPLtTocEFbUwFZL9gFxb4bDn1DPjzehA3afHeBYOdzPQ2NT3ypNJnNu4QIDAQAB\nAoGBAIdsZQbQ5QNqaUvguP8g+3aytUeiBF/EcuPhxnqOO2b3+cFHnrr7w7mxGNn0\n1VQqp1N0bM4rUeeqVtHF32Z15eBRM1cR+2OA4Tg1bs91OmC0Btpq/zNPGzhQCeN7\nNEXsnzJhP7MOg8RmXGL89vDMJfjGrg3bsBGQmTezJelAK7wJAkEAx3tzafAUlWGv\nwW5a1U2eRBKGVXXUgdnvn3TLaLArhDzzLJ4+o/42p9kAo4crVWRve/IZPF+wydb1\nLyCfs72qhwJBAMOPVUKecFj9sD3gVheMsYNPtxR6P1goHQkX6GGSLF1in5hweuoq\nhOMj1OR9ZzSRi27g0enrpoCanl4L9h9FbVcCQGHPUCnTg+Qy/8ByYatQ4ZczFhb1\nLXt15p5i4BG2v7+ZOwrXlJNIZHgsWLnV3xOBqYA2ltUZfk+ZTKMM9gFlsCUCQQCK\nga0gZvkpflxiJs6zFTnwx/ficAcHWDngY+d5m78CUUS6Agh8a6r8+TbishLzv5Xi\n7SafqACgm2JJN+2VDmY3AkBefIidvB3re7rBkUa/7x0AzXE1KIqDTHsyA1+Zw/+5\nDVyMxqPfW1XvQj5Vx2naUio7gy3zg5Y+v7+LbJY2g7Cc\n-----END RSA PRIVATE KEY-----",
      'server_name' => 'eXample.de',
      'organization_guid' => 'a-valid-org-guid',
      'created_at' => '2013-07-03T07:52:05Z',
      'updated_at' => '2013-07-03T07:52:05Z'
    }
  end

  let :valid_payload_cert_list_entry do
    'virtual_host_service_worker/tmp/haproxy/certificates/example.de.pem [alpn h2 ssl-min-ver TLSv1.2] example.de'
  end

  let :valid_payload2 do
    {
      'id' => 2,
      'ssl_certificate' =>
      "-----BEGIN CERTIFICATE-----\nMIID1DCCAbwCAQEwDQYJKoZIhvcNAQEFBQAwgYgxCzAJBgNVBAYTAkRFMREwDwYD\nVQQIEwhTYWFybGFuZDEVMBMGA1UEBxMMU2FhcmJydWVja2VuMQ0wCwYDVQQKEwRh\ndnRxMRAwDgYDVQQLEwdob3N0aW5nMQ0wCwYDVQQDEwRvbGxpMR8wHQYJKoZIhvcN\nAQkBFhBvd29sZkBhdmFydGVxLmRlMB4XDTEzMDYyNTA3NDg1MloXDTE0MDYyNTA3\nNDg1MlowWzELMAkGA1UEBhMCREUxEzARBgNVBAgTClNvbWUtU3RhdGUxCzAJBgNV\nBAcTAnNiMQwwCgYDVQQKEwNvcmcxDTALBgNVBAsTBHVuaXQxDTALBgNVBAMTBG5h\nbWUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAJhiuU8QqHPlk+HEpcu861BH\ngVDUTOkjcqTHmWBcOafykhfCUrLe6gU1NHgA1z2vixuX87RCEqHb99wwWurCEc79\nyc+9LG2Va6khuC+X8xEH9/W0qul7E8u1OhwQVtTAVkv2AXFvhsOfUM+PN6EDdp8d\n4Fg53M9DY1PfKk0mc27hAgMBAAEwDQYJKoZIhvcNAQEFBQADggIBABbt7WxEu6A+\n+Jszqm3j7UOT0JRcCb8QVjNQlejtpjpntQrRLUWl4YbCAtGTSLAIJ8x3zB8aOEQx\nsZQ7BcVQipNgr3P3wSzCdFPGaqe5IuXq0UypmHjr854G+Dt997CIuvH1g9Qylnck\npClpswMhltvnkcjPGEGiBtH5dXyVrRklXzSDHmX4vg5dv1GVLpEnq5XrvKypN/Hq\nzuWvyd6FUuXZ6BMlrfUoa4mZTxY3FGpcoqJugKAX5GOiNLz9sNpG4X9X37QnVPKE\n0BHdkJoyTuAgaEH+/3bYNrx+VvU1mvY+M6QPr2joLLDtTro1M1+oOMyXwK99e2lS\n3K0l6S546A2Po4Kw5txMz9ETId5N3cHo1hwwirGItLSFblNWitsLG56eW+sE+NoV\nqh4F1fYl6XPcRlqel5H29a8uQWN3jWsDDnsih5PCvEEPMAJ+E+vDTNBo4bGeKHw5\nmcnrksdX9+yqwtT5uev/7PXM6IdMTB+VxW6n0fiNa/nhMApDmHvVrxSSaht7QxiY\n9T/X2Hd8SgTZAjeTbgTqxvhyAh1Y24ti6yIvUj35oZUlg5teO6W9LQOSklHgy7MH\nnenMSGo4crCtBmTLWtqxhuizKD7OEEenXOUeGCDeDDGZOOgCcw9oVk5ZErhndTqR\n7BeVZ1Q+foNw3Yl5o46J5K5AvIulzMCP\n-----END CERTIFICATE-----",
      'ssl_ca_certificate' =>
      "-----BEGIN CERTIFICATE-----\n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\n-----END CERTIFICATE-----",
      'ssl_key' =>
      "-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQCYYrlPEKhz5ZPhxKXLvOtQR4FQ1EzpI3Kkx5lgXDmn8pIXwlKy\n3uoFNTR4ANc9r4sbl/O0QhKh2/fcMFrqwhHO/cnPvSxtlWupIbgvl/MRB/f1tKrp\nexPLtTocEFbUwFZL9gFxb4bDn1DPjzehA3afHeBYOdzPQ2NT3ypNJnNu4QIDAQAB\nAoGBAIdsZQbQ5QNqaUvguP8g+3aytUeiBF/EcuPhxnqOO2b3+cFHnrr7w7mxGNn0\n1VQqp1N0bM4rUeeqVtHF32Z15eBRM1cR+2OA4Tg1bs91OmC0Btpq/zNPGzhQCeN7\nNEXsnzJhP7MOg8RmXGL89vDMJfjGrg3bsBGQmTezJelAK7wJAkEAx3tzafAUlWGv\nwW5a1U2eRBKGVXXUgdnvn3TLaLArhDzzLJ4+o/42p9kAo4crVWRve/IZPF+wydb1\nLyCfs72qhwJBAMOPVUKecFj9sD3gVheMsYNPtxR6P1goHQkX6GGSLF1in5hweuoq\nhOMj1OR9ZzSRi27g0enrpoCanl4L9h9FbVcCQGHPUCnTg+Qy/8ByYatQ4ZczFhb1\nLXt15p5i4BG2v7+ZOwrXlJNIZHgsWLnV3xOBqYA2ltUZfk+ZTKMM9gFlsCUCQQCK\nga0gZvkpflxiJs6zFTnwx/ficAcHWDngY+d5m78CUUS6Agh8a6r8+TbishLzv5Xi\n7SafqACgm2JJN+2VDmY3AkBefIidvB3re7rBkUa/7x0AzXE1KIqDTHsyA1+Zw/+5\nDVyMxqPfW1XvQj5Vx2naUio7gy3zg5Y+v7+LbJY2g7Cc\n-----END RSA PRIVATE KEY-----",
      'server_name' => 'test.de',
      'organization_guid' => 'a-valid-org-guid',
      'created_at' => '2013-07-03T07:52:05Z',
      'updated_at' => '2013-07-03T07:52:05Z'
    }
  end

  let :valid_payload2_cert_list_entry do
    'virtual_host_service_worker/tmp/haproxy/certificates/test.de.pem [alpn h2 ssl-min-ver TLSv1.2] test.de'
  end

  let :valid_payload_with_wildcard_server_name do
    {
      'id' => 1,
      'ssl_certificate' =>
      "-----BEGIN CERTIFICATE-----\nMIID1DCCAbwCAQEwDQYJKoZIhvcNAQEFBQAwgYgxCzAJBgNVBAYTAkRFMREwDwYD\nVQQIEwhTYWFybGFuZDEVMBMGA1UEBxMMU2FhcmJydWVja2VuMQ0wCwYDVQQKEwRh\ndnRxMRAwDgYDVQQLEwdob3N0aW5nMQ0wCwYDVQQDEwRvbGxpMR8wHQYJKoZIhvcN\nAQkBFhBvd29sZkBhdmFydGVxLmRlMB4XDTEzMDYyNTA3NDg1MloXDTE0MDYyNTA3\nNDg1MlowWzELMAkGA1UEBhMCREUxEzARBgNVBAgTClNvbWUtU3RhdGUxCzAJBgNV\nBAcTAnNiMQwwCgYDVQQKEwNvcmcxDTALBgNVBAsTBHVuaXQxDTALBgNVBAMTBG5h\nbWUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAJhiuU8QqHPlk+HEpcu861BH\ngVDUTOkjcqTHmWBcOafykhfCUrLe6gU1NHgA1z2vixuX87RCEqHb99wwWurCEc79\nyc+9LG2Va6khuC+X8xEH9/W0qul7E8u1OhwQVtTAVkv2AXFvhsOfUM+PN6EDdp8d\n4Fg53M9DY1PfKk0mc27hAgMBAAEwDQYJKoZIhvcNAQEFBQADggIBABbt7WxEu6A+\n+Jszqm3j7UOT0JRcCb8QVjNQlejtpjpntQrRLUWl4YbCAtGTSLAIJ8x3zB8aOEQx\nsZQ7BcVQipNgr3P3wSzCdFPGaqe5IuXq0UypmHjr854G+Dt997CIuvH1g9Qylnck\npClpswMhltvnkcjPGEGiBtH5dXyVrRklXzSDHmX4vg5dv1GVLpEnq5XrvKypN/Hq\nzuWvyd6FUuXZ6BMlrfUoa4mZTxY3FGpcoqJugKAX5GOiNLz9sNpG4X9X37QnVPKE\n0BHdkJoyTuAgaEH+/3bYNrx+VvU1mvY+M6QPr2joLLDtTro1M1+oOMyXwK99e2lS\n3K0l6S546A2Po4Kw5txMz9ETId5N3cHo1hwwirGItLSFblNWitsLG56eW+sE+NoV\nqh4F1fYl6XPcRlqel5H29a8uQWN3jWsDDnsih5PCvEEPMAJ+E+vDTNBo4bGeKHw5\nmcnrksdX9+yqwtT5uev/7PXM6IdMTB+VxW6n0fiNa/nhMApDmHvVrxSSaht7QxiY\n9T/X2Hd8SgTZAjeTbgTqxvhyAh1Y24ti6yIvUj35oZUlg5teO6W9LQOSklHgy7MH\nnenMSGo4crCtBmTLWtqxhuizKD7OEEenXOUeGCDeDDGZOOgCcw9oVk5ZErhndTqR\n7BeVZ1Q+foNw3Yl5o46J5K5AvIulzMCP\n-----END CERTIFICATE-----",
      'ssl_ca_certificate' =>
      "-----BEGIN CERTIFICATE-----\n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\n-----END CERTIFICATE-----",
      'ssl_key' =>
      "-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQCYYrlPEKhz5ZPhxKXLvOtQR4FQ1EzpI3Kkx5lgXDmn8pIXwlKy\n3uoFNTR4ANc9r4sbl/O0QhKh2/fcMFrqwhHO/cnPvSxtlWupIbgvl/MRB/f1tKrp\nexPLtTocEFbUwFZL9gFxb4bDn1DPjzehA3afHeBYOdzPQ2NT3ypNJnNu4QIDAQAB\nAoGBAIdsZQbQ5QNqaUvguP8g+3aytUeiBF/EcuPhxnqOO2b3+cFHnrr7w7mxGNn0\n1VQqp1N0bM4rUeeqVtHF32Z15eBRM1cR+2OA4Tg1bs91OmC0Btpq/zNPGzhQCeN7\nNEXsnzJhP7MOg8RmXGL89vDMJfjGrg3bsBGQmTezJelAK7wJAkEAx3tzafAUlWGv\nwW5a1U2eRBKGVXXUgdnvn3TLaLArhDzzLJ4+o/42p9kAo4crVWRve/IZPF+wydb1\nLyCfs72qhwJBAMOPVUKecFj9sD3gVheMsYNPtxR6P1goHQkX6GGSLF1in5hweuoq\nhOMj1OR9ZzSRi27g0enrpoCanl4L9h9FbVcCQGHPUCnTg+Qy/8ByYatQ4ZczFhb1\nLXt15p5i4BG2v7+ZOwrXlJNIZHgsWLnV3xOBqYA2ltUZfk+ZTKMM9gFlsCUCQQCK\nga0gZvkpflxiJs6zFTnwx/ficAcHWDngY+d5m78CUUS6Agh8a6r8+TbishLzv5Xi\n7SafqACgm2JJN+2VDmY3AkBefIidvB3re7rBkUa/7x0AzXE1KIqDTHsyA1+Zw/+5\nDVyMxqPfW1XvQj5Vx2naUio7gy3zg5Y+v7+LbJY2g7Cc\n-----END RSA PRIVATE KEY-----",
      'server_name' => '*.eXample.de',
      'organization_guid' => 'a-valid-org-guid',
      'created_at' => '2013-07-03T07:52:05Z',
      'updated_at' => '2013-07-03T07:52:05Z'
    }
  end

  let :valid_payload_with_wildcard_cert_list_entry do
    'virtual_host_service_worker/tmp/haproxy/certificates/wild.example.de.pem [alpn h2 ssl-min-ver TLSv1.2] *.example.de'
  end

  let :valid_payload_with_empty_ca_cert do
    {
      'id' => 1,
      'ssl_certificate' =>
      "-----BEGIN CERTIFICATE-----\nMIID1DCCAbwCAQEwDQYJKoZIhvcNAQEFBQAwgYgxCzAJBgNVBAYTAkRFMREwDwYD\nVQQIEwhTYWFybGFuZDEVMBMGA1UEBxMMU2FhcmJydWVja2VuMQ0wCwYDVQQKEwRh\ndnRxMRAwDgYDVQQLEwdob3N0aW5nMQ0wCwYDVQQDEwRvbGxpMR8wHQYJKoZIhvcN\nAQkBFhBvd29sZkBhdmFydGVxLmRlMB4XDTEzMDYyNTA3NDg1MloXDTE0MDYyNTA3\nNDg1MlowWzELMAkGA1UEBhMCREUxEzARBgNVBAgTClNvbWUtU3RhdGUxCzAJBgNV\nBAcTAnNiMQwwCgYDVQQKEwNvcmcxDTALBgNVBAsTBHVuaXQxDTALBgNVBAMTBG5h\nbWUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAJhiuU8QqHPlk+HEpcu861BH\ngVDUTOkjcqTHmWBcOafykhfCUrLe6gU1NHgA1z2vixuX87RCEqHb99wwWurCEc79\nyc+9LG2Va6khuC+X8xEH9/W0qul7E8u1OhwQVtTAVkv2AXFvhsOfUM+PN6EDdp8d\n4Fg53M9DY1PfKk0mc27hAgMBAAEwDQYJKoZIhvcNAQEFBQADggIBABbt7WxEu6A+\n+Jszqm3j7UOT0JRcCb8QVjNQlejtpjpntQrRLUWl4YbCAtGTSLAIJ8x3zB8aOEQx\nsZQ7BcVQipNgr3P3wSzCdFPGaqe5IuXq0UypmHjr854G+Dt997CIuvH1g9Qylnck\npClpswMhltvnkcjPGEGiBtH5dXyVrRklXzSDHmX4vg5dv1GVLpEnq5XrvKypN/Hq\nzuWvyd6FUuXZ6BMlrfUoa4mZTxY3FGpcoqJugKAX5GOiNLz9sNpG4X9X37QnVPKE\n0BHdkJoyTuAgaEH+/3bYNrx+VvU1mvY+M6QPr2joLLDtTro1M1+oOMyXwK99e2lS\n3K0l6S546A2Po4Kw5txMz9ETId5N3cHo1hwwirGItLSFblNWitsLG56eW+sE+NoV\nqh4F1fYl6XPcRlqel5H29a8uQWN3jWsDDnsih5PCvEEPMAJ+E+vDTNBo4bGeKHw5\nmcnrksdX9+yqwtT5uev/7PXM6IdMTB+VxW6n0fiNa/nhMApDmHvVrxSSaht7QxiY\n9T/X2Hd8SgTZAjeTbgTqxvhyAh1Y24ti6yIvUj35oZUlg5teO6W9LQOSklHgy7MH\nnenMSGo4crCtBmTLWtqxhuizKD7OEEenXOUeGCDeDDGZOOgCcw9oVk5ZErhndTqR\n7BeVZ1Q+foNw3Yl5o46J5K5AvIulzMCP\n-----END CERTIFICATE-----",
      'ssl_ca_certificate' =>
      nil,
      'ssl_key' =>
      "-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQCYYrlPEKhz5ZPhxKXLvOtQR4FQ1EzpI3Kkx5lgXDmn8pIXwlKy\n3uoFNTR4ANc9r4sbl/O0QhKh2/fcMFrqwhHO/cnPvSxtlWupIbgvl/MRB/f1tKrp\nexPLtTocEFbUwFZL9gFxb4bDn1DPjzehA3afHeBYOdzPQ2NT3ypNJnNu4QIDAQAB\nAoGBAIdsZQbQ5QNqaUvguP8g+3aytUeiBF/EcuPhxnqOO2b3+cFHnrr7w7mxGNn0\n1VQqp1N0bM4rUeeqVtHF32Z15eBRM1cR+2OA4Tg1bs91OmC0Btpq/zNPGzhQCeN7\nNEXsnzJhP7MOg8RmXGL89vDMJfjGrg3bsBGQmTezJelAK7wJAkEAx3tzafAUlWGv\nwW5a1U2eRBKGVXXUgdnvn3TLaLArhDzzLJ4+o/42p9kAo4crVWRve/IZPF+wydb1\nLyCfs72qhwJBAMOPVUKecFj9sD3gVheMsYNPtxR6P1goHQkX6GGSLF1in5hweuoq\nhOMj1OR9ZzSRi27g0enrpoCanl4L9h9FbVcCQGHPUCnTg+Qy/8ByYatQ4ZczFhb1\nLXt15p5i4BG2v7+ZOwrXlJNIZHgsWLnV3xOBqYA2ltUZfk+ZTKMM9gFlsCUCQQCK\nga0gZvkpflxiJs6zFTnwx/ficAcHWDngY+d5m78CUUS6Agh8a6r8+TbishLzv5Xi\n7SafqACgm2JJN+2VDmY3AkBefIidvB3re7rBkUa/7x0AzXE1KIqDTHsyA1+Zw/+5\nDVyMxqPfW1XvQj5Vx2naUio7gy3zg5Y+v7+LbJY2g7Cc\n-----END RSA PRIVATE KEY-----",
      'server_name' => '*.eXample.de',
      'organization_guid' => 'a-valid-org-guid',
      'created_at' => '2013-07-03T07:52:05Z',
      'updated_at' => '2013-07-03T07:52:05Z'
    }
  end

  let :valid_haproxy_config do
    File.read('spec/support/haproxy.cfg')
  end

  let :invalid_haproxy_config do
    File.read('spec/support/invalid_haproxy.cfg')
  end

  describe '.setup_v_host' do
    before :each do
    end

    context 'it should requeu tasks if the instance limit has been reached' do
      it 'should requeu when limit is reached' do
      end
      
    end

    context 'with a valid cert, ca cert and ssl key' do
      it 'should create .pem file' do
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload)
        expect(File.exist?("#{APP_CONFIG['haproxy_cert_dir']}/example.de.pem")).to be true
      end

      it 'should add cert.pem entry to cert-list' do
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload)

        expect(haproxy_cert_list_content).to include valid_payload_cert_list_entry
      end

      it 'should not overwrite other cert-list entries' do
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload2)
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload_with_wildcard_server_name)

        expect(haproxy_cert_list_content).to include valid_payload2_cert_list_entry
        expect(haproxy_cert_list_content).to include valid_payload_with_wildcard_cert_list_entry
      end

      it 'should reload the haproxy configuration' do
        VirtualHostServiceWorker::HaproxyVHostWriter.expects(:reload_config).once
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload)
      end
    end

    context 'with a wildcard server name' do
      it 'should replace the asterix in the certificates file name' do
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload_with_wildcard_server_name)
        expect(File.exist?("#{APP_CONFIG['haproxy_cert_dir']}/wild.example.de.pem")).to be true
      end

      it 'should add cert.pem entry to cert-list with wildcard' do
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload_with_wildcard_server_name)

        expect(haproxy_cert_list_content).to include 'virtual_host_service_worker/tmp/haproxy/certificates/wild.example.de.pem [alpn h2 ssl-min-ver TLSv1.2] *.example.de'
      end
    end

    context 'with multiple alias' do
      let :valid_payload do
        {
          'id' => 1,
          'ssl_certificate' =>
          "-----BEGIN CERTIFICATE-----\nMIID1DCCAbwCAQEwDQYJKoZIhvcNAQEFBQAwgYgxCzAJBgNVBAYTAkRFMREwDwYD\nVQQIEwhTYWFybGFuZDEVMBMGA1UEBxMMU2FhcmJydWVja2VuMQ0wCwYDVQQKEwRh\ndnRxMRAwDgYDVQQLEwdob3N0aW5nMQ0wCwYDVQQDEwRvbGxpMR8wHQYJKoZIhvcN\nAQkBFhBvd29sZkBhdmFydGVxLmRlMB4XDTEzMDYyNTA3NDg1MloXDTE0MDYyNTA3\nNDg1MlowWzELMAkGA1UEBhMCREUxEzARBgNVBAgTClNvbWUtU3RhdGUxCzAJBgNV\nBAcTAnNiMQwwCgYDVQQKEwNvcmcxDTALBgNVBAsTBHVuaXQxDTALBgNVBAMTBG5h\nbWUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAJhiuU8QqHPlk+HEpcu861BH\ngVDUTOkjcqTHmWBcOafykhfCUrLe6gU1NHgA1z2vixuX87RCEqHb99wwWurCEc79\nyc+9LG2Va6khuC+X8xEH9/W0qul7E8u1OhwQVtTAVkv2AXFvhsOfUM+PN6EDdp8d\n4Fg53M9DY1PfKk0mc27hAgMBAAEwDQYJKoZIhvcNAQEFBQADggIBABbt7WxEu6A+\n+Jszqm3j7UOT0JRcCb8QVjNQlejtpjpntQrRLUWl4YbCAtGTSLAIJ8x3zB8aOEQx\nsZQ7BcVQipNgr3P3wSzCdFPGaqe5IuXq0UypmHjr854G+Dt997CIuvH1g9Qylnck\npClpswMhltvnkcjPGEGiBtH5dXyVrRklXzSDHmX4vg5dv1GVLpEnq5XrvKypN/Hq\nzuWvyd6FUuXZ6BMlrfUoa4mZTxY3FGpcoqJugKAX5GOiNLz9sNpG4X9X37QnVPKE\n0BHdkJoyTuAgaEH+/3bYNrx+VvU1mvY+M6QPr2joLLDtTro1M1+oOMyXwK99e2lS\n3K0l6S546A2Po4Kw5txMz9ETId5N3cHo1hwwirGItLSFblNWitsLG56eW+sE+NoV\nqh4F1fYl6XPcRlqel5H29a8uQWN3jWsDDnsih5PCvEEPMAJ+E+vDTNBo4bGeKHw5\nmcnrksdX9+yqwtT5uev/7PXM6IdMTB+VxW6n0fiNa/nhMApDmHvVrxSSaht7QxiY\n9T/X2Hd8SgTZAjeTbgTqxvhyAh1Y24ti6yIvUj35oZUlg5teO6W9LQOSklHgy7MH\nnenMSGo4crCtBmTLWtqxhuizKD7OEEenXOUeGCDeDDGZOOgCcw9oVk5ZErhndTqR\n7BeVZ1Q+foNw3Yl5o46J5K5AvIulzMCP\n-----END CERTIFICATE-----",
          'ssl_ca_certificate' =>
          "-----BEGIN CERTIFICATE-----\nMIIGhjCCBG6gAwIBAgIJAKrMa3+Wsy4NMA0GCSqGSIb3DQEBBQUAMIGIMQswCQYD\nVQQGEwJERTERMA8GA1UECBMIU2FhcmxhbmQxFTATBgNVBAcTDFNhYXJicnVlY2tl\nbjENMAsGA1UEChMEYXZ0cTEQMA4GA1UECxMHaG9zdGluZzENMAsGA1UEAxMEb2xs\naTEfMB0GCSqGSIb3DQEJARYQb3dvbGZAYXZhcnRlcS5kZTAeFw0xMzA2MjUwNzQ1\nNTlaFw0xNDA2MjUwNzQ1NTlaMIGIMQswCQYDVQQGEwJERTERMA8GA1UECBMIU2Fh\ncmxhbmQxFTATBgNVBAcTDFNhYXJicnVlY2tlbjENMAsGA1UEChMEYXZ0cTEQMA4G\nA1UECxMHaG9zdGluZzENMAsGA1UEAxMEb2xsaTEfMB0GCSqGSIb3DQEJARYQb3dv\nbGZAYXZhcnRlcS5kZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANub\nfGLk3i3Q972AnPES7GJly1TD7mwue/JcWP8LdFLFxVDUd0nM3lX+XvpEHWIdPIpd\njJkuuRz9EP2d6deV5xiwKKwvmf7C3p3NUm/6veEWrQ47pgceMeJwpDXEWYqB8a8L\nrkrYygsCc3ffPA7rAV/8Cvoih61NRKWLgACSucwIfe9r+kH/GwlVDHHzx2/or0hb\n6ExvtlscNVWnVk93FAS+SJgt27EXn/1nW70vsZ4FHwLoVn/C5ZGNRPPXLMxzz9tk\nsKtwq2WwP4ZK9xVIOUprUuHzNkHoOhmaNPJeKhgEnSXLPTwbb3o++BjE5wU5eX7o\nApgWa6eaz+BjbswcE+wUxoybAtFM/UlmYpUrwr4ec1ckm6ukdmR0duRYxT3fJOxS\nEQmKK0Do/AsN557B8zLjSrqNzSyPz6VQJdIdiOBPe9LvOyK6ftyh+hQtAjZKpUy1\nK7//52LtdVV2DxjRnccQmWLRSikzNSnQ3wKPQ6VojitRe7YeQOQ2Kw45UvB5QRj2\nkbPChJKdjQsCCjx+TDlPo3xVHMHm8YiwHKYbbtQNPVDXp1xDdawiswzNU6EMFflm\nNHd336BeebTAMh7luJUN6DY+vP41aq6QJkxwRLbZH79mQ1Nj773wzTGKkGUIWrQm\nL8Qqp1TRVgN6I17wC1Cq/Lp8eyeKB1wrlSJdaWdTAgMBAAGjgfAwge0wHQYDVR0O\nBBYEFO+kqolJxPkZY5p/558oNomVA6PTMIG9BgNVHSMEgbUwgbKAFO+kqolJxPkZ\nY5p/558oNomVA6PToYGOpIGLMIGIMQswCQYDVQQGEwJERTERMA8GA1UECBMIU2Fh\ncmxhbmQxFTATBgNVBAcTDFNhYXJicnVlY2tlbjENMAsGA1UEChMEYXZ0cTEQMA4G\nA1UECxMHaG9zdGluZzENMAsGA1UEAxMEb2xsaTEfMB0GCSqGSIb3DQEJARYQb3dv\nbGZAYXZhcnRlcS5kZYIJAKrMa3+Wsy4NMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcN\nAQEFBQADggIBAFpU/B6KNUCMtqOWgH3cb7eo3OS6vvdZFsUCrTn3CtMh5qDd6YQx\nsiQilwDfqvX08/XXe2GtjTpRxtvfnwCyLtEk9gwqZNwcQGaHGy2kIs9GpTc1TMzi\nHMs5PPFl3eihm4UvCmJxJRH8+Sp0PrkRo6GORtNHW4b0POW/sgK17Z82Ckpao0r4\n8zXRcgka/cWs3+oIsUcmKlTJib6gjsNHxJrSIl9gr8eDz3vDLUtG4CXKrVjkJyiX\nKAFLS3K6O+8CacBv4ZqFiqtZe0YCUR3a4CZsVrn/88kqfSFgCd0yPfpYyx7v/og7\nhtB4GNCY9aOpUXpEl8PpFuOhbtZiAzXKnKRCLg26af3W6e1KMvjeZky0ysNQPhs7\n3ln+sVfY9pnQiDbZmsvQYSW4BKVc0eHEVoJe6Fz4F0860/tEMzh62j8WFGu9+kkb\ny5bydI3gEiLjJEMHrvnVN5BhfyWXlJjJJWmWlDR/RcspoaTDo3671sKsx/hLgVd9\n9IY9cn62EusnCZbdwTdSULavS/hWD5FwWBg/RSzgHt7dCZ4vDf4cKnD2a8UzMNv9\n9hJLoJF0gAcQOMe21nM1sHuiYAlgS1gEwdND6PEcz2OSNQzkmipscMtIpN0CWqlI\nNZbleCAVFndhuSHuLxU27IhCvh/zb9XcBfMLaH7ul03XO7SHqzASCxwZ\n-----END CERTIFICATE-----",
          'ssl_key' =>
          "-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQCYYrlPEKhz5ZPhxKXLvOtQR4FQ1EzpI3Kkx5lgXDmn8pIXwlKy\n3uoFNTR4ANc9r4sbl/O0QhKh2/fcMFrqwhHO/cnPvSxtlWupIbgvl/MRB/f1tKrp\nexPLtTocEFbUwFZL9gFxb4bDn1DPjzehA3afHeBYOdzPQ2NT3ypNJnNu4QIDAQAB\nAoGBAIdsZQbQ5QNqaUvguP8g+3aytUeiBF/EcuPhxnqOO2b3+cFHnrr7w7mxGNn0\n1VQqp1N0bM4rUeeqVtHF32Z15eBRM1cR+2OA4Tg1bs91OmC0Btpq/zNPGzhQCeN7\nNEXsnzJhP7MOg8RmXGL89vDMJfjGrg3bsBGQmTezJelAK7wJAkEAx3tzafAUlWGv\nwW5a1U2eRBKGVXXUgdnvn3TLaLArhDzzLJ4+o/42p9kAo4crVWRve/IZPF+wydb1\nLyCfs72qhwJBAMOPVUKecFj9sD3gVheMsYNPtxR6P1goHQkX6GGSLF1in5hweuoq\nhOMj1OR9ZzSRi27g0enrpoCanl4L9h9FbVcCQGHPUCnTg+Qy/8ByYatQ4ZczFhb1\nLXt15p5i4BG2v7+ZOwrXlJNIZHgsWLnV3xOBqYA2ltUZfk+ZTKMM9gFlsCUCQQCK\nga0gZvkpflxiJs6zFTnwx/ficAcHWDngY+d5m78CUUS6Agh8a6r8+TbishLzv5Xi\n7SafqACgm2JJN+2VDmY3AkBefIidvB3re7rBkUa/7x0AzXE1KIqDTHsyA1+Zw/+5\nDVyMxqPfW1XvQj5Vx2naUio7gy3zg5Y+v7+LbJY2g7Cc\n-----END RSA PRIVATE KEY-----",
          'server_name' => 'eXample.de',
          'server_aliases' => '*.example.de www.example.de',
          'organization_guid' => 'a-valid-org-guid',
          'created_at' => '2013-07-03T07:52:05Z',
          'updated_at' => '2013-07-03T07:52:05Z'
        }
      end

      let :valid_payload_with_comma do
        {
          'id' => 1,
          'ssl_certificate' =>
          "-----BEGIN CERTIFICATE-----\nMIID1DCCAbwCAQEwDQYJKoZIhvcNAQEFBQAwgYgxCzAJBgNVBAYTAkRFMREwDwYD\nVQQIEwhTYWFybGFuZDEVMBMGA1UEBxMMU2FhcmJydWVja2VuMQ0wCwYDVQQKEwRh\ndnRxMRAwDgYDVQQLEwdob3N0aW5nMQ0wCwYDVQQDEwRvbGxpMR8wHQYJKoZIhvcN\nAQkBFhBvd29sZkBhdmFydGVxLmRlMB4XDTEzMDYyNTA3NDg1MloXDTE0MDYyNTA3\nNDg1MlowWzELMAkGA1UEBhMCREUxEzARBgNVBAgTClNvbWUtU3RhdGUxCzAJBgNV\nBAcTAnNiMQwwCgYDVQQKEwNvcmcxDTALBgNVBAsTBHVuaXQxDTALBgNVBAMTBG5h\nbWUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAJhiuU8QqHPlk+HEpcu861BH\ngVDUTOkjcqTHmWBcOafykhfCUrLe6gU1NHgA1z2vixuX87RCEqHb99wwWurCEc79\nyc+9LG2Va6khuC+X8xEH9/W0qul7E8u1OhwQVtTAVkv2AXFvhsOfUM+PN6EDdp8d\n4Fg53M9DY1PfKk0mc27hAgMBAAEwDQYJKoZIhvcNAQEFBQADggIBABbt7WxEu6A+\n+Jszqm3j7UOT0JRcCb8QVjNQlejtpjpntQrRLUWl4YbCAtGTSLAIJ8x3zB8aOEQx\nsZQ7BcVQipNgr3P3wSzCdFPGaqe5IuXq0UypmHjr854G+Dt997CIuvH1g9Qylnck\npClpswMhltvnkcjPGEGiBtH5dXyVrRklXzSDHmX4vg5dv1GVLpEnq5XrvKypN/Hq\nzuWvyd6FUuXZ6BMlrfUoa4mZTxY3FGpcoqJugKAX5GOiNLz9sNpG4X9X37QnVPKE\n0BHdkJoyTuAgaEH+/3bYNrx+VvU1mvY+M6QPr2joLLDtTro1M1+oOMyXwK99e2lS\n3K0l6S546A2Po4Kw5txMz9ETId5N3cHo1hwwirGItLSFblNWitsLG56eW+sE+NoV\nqh4F1fYl6XPcRlqel5H29a8uQWN3jWsDDnsih5PCvEEPMAJ+E+vDTNBo4bGeKHw5\nmcnrksdX9+yqwtT5uev/7PXM6IdMTB+VxW6n0fiNa/nhMApDmHvVrxSSaht7QxiY\n9T/X2Hd8SgTZAjeTbgTqxvhyAh1Y24ti6yIvUj35oZUlg5teO6W9LQOSklHgy7MH\nnenMSGo4crCtBmTLWtqxhuizKD7OEEenXOUeGCDeDDGZOOgCcw9oVk5ZErhndTqR\n7BeVZ1Q+foNw3Yl5o46J5K5AvIulzMCP\n-----END CERTIFICATE-----",
          'ssl_ca_certificate' =>
          "-----BEGIN CERTIFICATE-----\n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\n-----END CERTIFICATE-----",
          'ssl_key' =>
          "-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQCYYrlPEKhz5ZPhxKXLvOtQR4FQ1EzpI3Kkx5lgXDmn8pIXwlKy\n3uoFNTR4ANc9r4sbl/O0QhKh2/fcMFrqwhHO/cnPvSxtlWupIbgvl/MRB/f1tKrp\nexPLtTocEFbUwFZL9gFxb4bDn1DPjzehA3afHeBYOdzPQ2NT3ypNJnNu4QIDAQAB\nAoGBAIdsZQbQ5QNqaUvguP8g+3aytUeiBF/EcuPhxnqOO2b3+cFHnrr7w7mxGNn0\n1VQqp1N0bM4rUeeqVtHF32Z15eBRM1cR+2OA4Tg1bs91OmC0Btpq/zNPGzhQCeN7\nNEXsnzJhP7MOg8RmXGL89vDMJfjGrg3bsBGQmTezJelAK7wJAkEAx3tzafAUlWGv\nwW5a1U2eRBKGVXXUgdnvn3TLaLArhDzzLJ4+o/42p9kAo4crVWRve/IZPF+wydb1\nLyCfs72qhwJBAMOPVUKecFj9sD3gVheMsYNPtxR6P1goHQkX6GGSLF1in5hweuoq\nhOMj1OR9ZzSRi27g0enrpoCanl4L9h9FbVcCQGHPUCnTg+Qy/8ByYatQ4ZczFhb1\nLXt15p5i4BG2v7+ZOwrXlJNIZHgsWLnV3xOBqYA2ltUZfk+ZTKMM9gFlsCUCQQCK\nga0gZvkpflxiJs6zFTnwx/ficAcHWDngY+d5m78CUUS6Agh8a6r8+TbishLzv5Xi\n7SafqACgm2JJN+2VDmY3AkBefIidvB3re7rBkUa/7x0AzXE1KIqDTHsyA1+Zw/+5\nDVyMxqPfW1XvQj5Vx2naUio7gy3zg5Y+v7+LbJY2g7Cc\n-----END RSA PRIVATE KEY-----",
          'server_name' => 'eXample.de',
          'server_aliases' => '*.example.de,www.example.de',
          'organization_guid' => 'a-valid-org-guid',
          'created_at' => '2013-07-03T07:52:05Z',
          'updated_at' => '2013-07-03T07:52:05Z'
        }
      end

      let :valid_cert_file do
        'virtual_host_service_worker/tmp/haproxy/certificates/example.de.pem [alpn h2 ssl-min-ver TLSv1.2] example.de *.example.de www.example.de'
      end

      it 'should add cert.pem entry to cert-list with all aliases' do
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload)
        expect(haproxy_cert_list_content).to include(valid_cert_file)
      end

      it 'should add cert.pem entry to cert-list with all aliases separated with blank' do
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload_with_comma)
        expect(haproxy_cert_list_content).to include(valid_cert_file)
      end
    end
  end

  describe '.delete_v_host' do
    context 'with a existing virtual host' do
      before :each do
        system("rm -f #{APP_CONFIG['haproxy_cert_list']}")
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload)
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload2)
        VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(valid_payload_with_wildcard_server_name)
      end

      it 'should delete the pem file' do
        VirtualHostServiceWorker::HaproxyVHostWriter.delete_v_host('eXample.de')
        expect(File.exist?("#{APP_CONFIG['haproxy_cert_dir']}example.de.pem")).to be false
      end

      it 'should delete the pem file for wildcard' do
        VirtualHostServiceWorker::HaproxyVHostWriter.delete_v_host('*.eXample.de')
        expect(File.exist?("#{APP_CONFIG['haproxy_cert_dir']}wild.example.de.pem")).to be false
      end

      it 'should delete from the haproxy cert list' do
        expect(File.read(APP_CONFIG['haproxy_cert_list'])).to include(valid_payload2_cert_list_entry)
        VirtualHostServiceWorker::HaproxyVHostWriter.delete_v_host('test.de')
        expect(File.read(APP_CONFIG['haproxy_cert_list'])).to_not include(valid_payload2_cert_list_entry)
      end

      it 'should delete from the haproxy cert list for wildcard' do
        expect(File.read(APP_CONFIG['haproxy_cert_list'])).to include('wild.example.de.pem')
        VirtualHostServiceWorker::HaproxyVHostWriter.delete_v_host('*.eXample.de')
        expect(File.read(APP_CONFIG['haproxy_cert_list'])).to_not include('wild.example.de.pem')
      end

      it 'should reload the haproxy configuration' do
        VirtualHostServiceWorker::HaproxyVHostWriter.expects(:reload_config).once
        VirtualHostServiceWorker::HaproxyVHostWriter.delete_v_host('eXample.de')
      end
    end
  end

  describe '.config_valid' do
    context 'with a valid config file' do
      before :each do
        File.open(APP_CONFIG['haproxy_config'], 'w') do |f|
          f.write(valid_haproxy_config)
        end
      end

      it 'should be true' do
        expect(VirtualHostServiceWorker::HaproxyVHostWriter.config_valid?).to be true
      end
    end

    context 'with an invalid config file' do
      before :each do
        File.open(APP_CONFIG['haproxy_config'], 'w') do |f|
          f.write(invalid_haproxy_config)
        end
      end

      it 'should raise Exception' do
        APP_CONFIG['haproxy_config'] = File.expand_path('../tmp/haproxy/config/invalid_haproxy.cfg', __dir__)
        expect { VirtualHostServiceWorker::HaproxyVHostWriter.config_valid }.to raise_error
      end
    end
  end
end
