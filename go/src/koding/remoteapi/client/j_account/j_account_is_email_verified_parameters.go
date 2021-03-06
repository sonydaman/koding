package j_account

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/runtime"
	cr "github.com/go-openapi/runtime/client"

	strfmt "github.com/go-openapi/strfmt"

	"koding/remoteapi/models"
)

// NewJAccountIsEmailVerifiedParams creates a new JAccountIsEmailVerifiedParams object
// with the default values initialized.
func NewJAccountIsEmailVerifiedParams() *JAccountIsEmailVerifiedParams {
	var ()
	return &JAccountIsEmailVerifiedParams{

		timeout: cr.DefaultTimeout,
	}
}

// NewJAccountIsEmailVerifiedParamsWithTimeout creates a new JAccountIsEmailVerifiedParams object
// with the default values initialized, and the ability to set a timeout on a request
func NewJAccountIsEmailVerifiedParamsWithTimeout(timeout time.Duration) *JAccountIsEmailVerifiedParams {
	var ()
	return &JAccountIsEmailVerifiedParams{

		timeout: timeout,
	}
}

// NewJAccountIsEmailVerifiedParamsWithContext creates a new JAccountIsEmailVerifiedParams object
// with the default values initialized, and the ability to set a context for a request
func NewJAccountIsEmailVerifiedParamsWithContext(ctx context.Context) *JAccountIsEmailVerifiedParams {
	var ()
	return &JAccountIsEmailVerifiedParams{

		Context: ctx,
	}
}

/*JAccountIsEmailVerifiedParams contains all the parameters to send to the API endpoint
for the j account is email verified operation typically these are written to a http.Request
*/
type JAccountIsEmailVerifiedParams struct {

	/*Body
	  body of the request

	*/
	Body models.DefaultSelector
	/*ID
	  Mongo ID of target instance

	*/
	ID string

	timeout    time.Duration
	Context    context.Context
	HTTPClient *http.Client
}

// WithTimeout adds the timeout to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) WithTimeout(timeout time.Duration) *JAccountIsEmailVerifiedParams {
	o.SetTimeout(timeout)
	return o
}

// SetTimeout adds the timeout to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) SetTimeout(timeout time.Duration) {
	o.timeout = timeout
}

// WithContext adds the context to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) WithContext(ctx context.Context) *JAccountIsEmailVerifiedParams {
	o.SetContext(ctx)
	return o
}

// SetContext adds the context to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) SetContext(ctx context.Context) {
	o.Context = ctx
}

// WithBody adds the body to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) WithBody(body models.DefaultSelector) *JAccountIsEmailVerifiedParams {
	o.SetBody(body)
	return o
}

// SetBody adds the body to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) SetBody(body models.DefaultSelector) {
	o.Body = body
}

// WithID adds the id to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) WithID(id string) *JAccountIsEmailVerifiedParams {
	o.SetID(id)
	return o
}

// SetID adds the id to the j account is email verified params
func (o *JAccountIsEmailVerifiedParams) SetID(id string) {
	o.ID = id
}

// WriteToRequest writes these params to a swagger request
func (o *JAccountIsEmailVerifiedParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

	r.SetTimeout(o.timeout)
	var res []error

	if err := r.SetBodyParam(o.Body); err != nil {
		return err
	}

	// path param id
	if err := r.SetPathParam("id", o.ID); err != nil {
		return err
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}
