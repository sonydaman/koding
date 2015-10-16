package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	. "github.com/smartystreets/goconvey/convey"
)

func TestHealthCheckRemote(t *testing.T) {

	Convey("Should return no errors for working http servers", t, func() {
		ts := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {
				fmt.Fprint(w, "Welcome to SockJS!\n")
			}))
		defer ts.Close()

		// We can use the same url for inet and kontrol, since inet just
		// checks for no error
		c := &HealthChecker{
			HttpClient: &http.Client{
				Timeout: 4 * time.Second,
			},
			RemoteKiteAddress: ts.URL,
			RemoteHttpAddress: ts.URL,
		}

		So(c.CheckRemote(), ShouldBeNil)
	})

	Convey("Should return no internet if the inetAddress fails", t, func() {
		// Simulate no internet with a bad address
		c := &HealthChecker{
			HttpClient: &http.Client{
				Timeout: 4 * time.Second,
			},
			RemoteKiteAddress: "http://foo",
			RemoteHttpAddress: "http://bar",
		}

		err := c.CheckRemote()
		So(err, ShouldNotBeNil)
		So(err, ShouldHaveSameTypeAs, ErrHealthNoInternet{})
	})

	Convey("Should return no kontrol if the kontrolAddress fails", t, func() {
		tsNet := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {}))
		defer tsNet.Close()
		tsKon := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(http.StatusNotFound)
				fmt.Fprint(w, "404 not found")
			}))
		defer tsKon.Close()

		c := &HealthChecker{
			HttpClient: &http.Client{
				Timeout: 4 * time.Second,
			},
			RemoteKiteAddress: tsKon.URL,
			RemoteHttpAddress: tsNet.URL,
		}

		err := c.CheckRemote()
		So(err, ShouldNotBeNil)
		So(err, ShouldHaveSameTypeAs, ErrHealthNoKontrolHttp{})
	})

	Convey("Should return unexpected response if the kontrol response is.. unexpected", t, func() {
		tsNet := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {}))
		defer tsNet.Close()
		tsKon := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {
				fmt.Fprint(w, "foo bar baz\n")
			}))
		defer tsKon.Close()

		c := &HealthChecker{
			HttpClient: &http.Client{
				Timeout: 4 * time.Second,
			},
			RemoteKiteAddress: tsNet.URL,
			RemoteHttpAddress: tsKon.URL,
		}

		err := c.CheckRemote()
		So(err, ShouldNotBeNil)
		So(err, ShouldHaveSameTypeAs, ErrHealthUnexpectedResponse{})
	})

	Convey("Should timeout after X seconds", t, func() {
		// A valid http server, that takes 1 second longer than the
		// client timeout
		ts := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {
				time.Sleep(2 * time.Second)
				fmt.Fprint(w, "Welcome to SockJS!\n")
			}))
		defer ts.Close()

		c := &HealthChecker{
			HttpClient: &http.Client{
				Timeout: 1 * time.Second,
			},
			RemoteKiteAddress: ts.URL,
			RemoteHttpAddress: ts.URL,
		}

		err := c.CheckRemote()
		So(err, ShouldNotBeNil)
	})
}
