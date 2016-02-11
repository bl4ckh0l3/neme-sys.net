<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MarkExpressCheckout.aspx.cs" %>
<!DOCTYPE html>
<html>
	  <head>
		  <meta charset="utf-8" />
		  <meta name="viewport" content="width=device-width, initial-scale=1">
		  <title>PayPal Demo Portal</title>
		  <!--Including Bootstrap style files-->
		  <link href="css/bootstrap.min.css" rel="stylesheet">
		  <link href="css/bootstrap-responsive.min.css" rel="stylesheet">
	  </head>
	  <body>
		  <div class="container-fluid">
		  <div class="well">
			 <h2 class="text-center">
                 <img src="img/logo.jpg"/>Checkout with PayPal Demo</h2>
		  </div>
		  <div class="row-fluid">
      
      <div class="span4">
   </div>
   <div class="span5">
          <form class="form" method="POST" runat="server" id="MarkExpressCheckoutForm" action="SetExpressCheckout.aspx">
            <asp:HiddenField id="ITEM_NAME" runat="server" />
            <asp:HiddenField id="ITEM_ID" runat="server" />
            <asp:HiddenField id="ITEM_DESC" runat="server" />
            <asp:HiddenField id="ITEM_QUANTITY" runat="server" />
            <asp:HiddenField id="ITEM_AMOUNT" runat="server" />
            <asp:HiddenField id="TAX_AMOUNT" runat="server" />
            <asp:HiddenField id="SHIPPING_AMOUNT" runat="server" />
            <asp:HiddenField id="HANDLING_AMOUNT" runat="server" />
            <asp:HiddenField id="SHIPPING_DISCOUNT_AMOUNT" runat="server" />
            <asp:HiddenField id="INSURANCE_AMOUNT" runat="server" />
            <asp:HiddenField id="TOTAL_AMOUNT" runat="server" />
            <asp:HiddenField id="CURRENCY_CODE" runat="server" />
            <asp:HiddenField id="PAYMENT_TYPE" runat="server" />

               <div class="row-fluid">
                  <div class="span6 inner-span">
                        <p class="lead"><u>New Shipping Address</u></p>
                        <table>
                        <tr><td width="30%">First Name:</td><td><asp:TextBox runat="server" id="FIRST_NAME"  Text="Michael"/></td>
                            <td>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                    ControlToValidate="FIRST_NAME"
                                    ErrorMessage="*Required"
                                    ForeColor="Red">
                                </asp:RequiredFieldValidator>
                                                            </td></tr>
                        <tr><td>Last Name:</td><td><asp:TextBox runat="server" id="LAST_NAME"  Text="Woods"/></td>
                            <td>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                                    ControlToValidate="LAST_NAME"
                                    ErrorMessage="*Required"
                                    ForeColor="Red">
                                </asp:RequiredFieldValidator>
                                               </td>
                            </tr>
                        <tr><td>Street 1:</td><td><asp:TextBox runat="server" id="STREET_1" Text="55 East 52nd Street" /></td>
                            <td>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
                                    ControlToValidate="STREET_1"
                                    ErrorMessage="*Required"
                                    ForeColor="Red">
                                </asp:RequiredFieldValidator>
                                              </td></tr>
                        <tr><td>Street 2:</td><td><asp:TextBox runat="server" id="STREET_2"  Text="21st Floor"/></td></tr>
                        <tr><td>City:</td><td><asp:TextBox runat="server" id="CITY"  Text="New York"/></td><td>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
                                    ControlToValidate="CITY"
                                    ErrorMessage="*Required"
                                    ForeColor="Red">
                                </asp:RequiredFieldValidator>
                                          </td></tr>
                        <tr><td>State/Province:</td><td><asp:TextBox runat="server" id="STATE"  Text="NY"/></td>
                            <td>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server"
                                    ControlToValidate="STATE"
                                    ErrorMessage="*Required"
                                    ForeColor="Red">
                                </asp:RequiredFieldValidator>
                                                    </td></tr>
                        <tr><td>Postal Code:</td><td><asp:TextBox runat="server" id="POSTAL_CODE" Text="10022" /></td>
                            <td>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server"
                                    ControlToValidate="POSTAL_CODE"
                                    ErrorMessage="*Required"
                                    ForeColor="Red">
                                </asp:RequiredFieldValidator>
                                                 </td></tr>
                        <tr><td>Country:</td><td> <asp:DropDownList id="COUNTRY" runat="server">
                            <asp:ListItem value="AF">Afghanistan</asp:ListItem>
							<asp:ListItem value="AX">Aland Islands</asp:ListItem>
							<asp:ListItem value="AL">Albania</asp:ListItem>
							<asp:ListItem value="DZ">Algeria</asp:ListItem>
							<asp:ListItem value="AS">American Samoa</asp:ListItem>
							<asp:ListItem value="AD">Andorra</asp:ListItem>
							<asp:ListItem value="AO">Angola</asp:ListItem>
							<asp:ListItem value="AI">Anguilla</asp:ListItem>
							<asp:ListItem value="AQ">Antarctica</asp:ListItem>
							<asp:ListItem value="AG">Antigua and Barbuda</asp:ListItem>
							<asp:ListItem value="AR">Argentina</asp:ListItem>
							<asp:ListItem value="AM">Armenia</asp:ListItem>
							<asp:ListItem value="AW">Aruba</asp:ListItem>
							<asp:ListItem value="AU">Australia</asp:ListItem>
							<asp:ListItem value="AT">Austria</asp:ListItem>
							<asp:ListItem value="AZ">Azerbaijan</asp:ListItem>
							<asp:ListItem value="BS">Bahamas</asp:ListItem>
							<asp:ListItem value="BH">Bahrain</asp:ListItem>
							<asp:ListItem value="BD">Bangladesh</asp:ListItem>
							<asp:ListItem value="BB">Barbados</asp:ListItem>
							<asp:ListItem value="BY">Belarus</asp:ListItem>
							<asp:ListItem value="BE">Belgium</asp:ListItem>
							<asp:ListItem value="BZ">Belize</asp:ListItem>
							<asp:ListItem value="BJ">Benin</asp:ListItem>
							<asp:ListItem value="BM">Bermuda</asp:ListItem>
							<asp:ListItem value="BT">Bhutan</asp:ListItem>
							<asp:ListItem value="BO">Bolivia</asp:ListItem>
							<asp:ListItem value="BA">Bosnia and Herzegovina</asp:ListItem>
							<asp:ListItem value="BW">Botswana</asp:ListItem>
							<asp:ListItem value="BV">Bouvet Island</asp:ListItem>
							<asp:ListItem value="BR">Brazil</asp:ListItem>
							<asp:ListItem value="IO">British Indian Ocean Territory</asp:ListItem>
							<asp:ListItem value="BN">Brunei Darussalam</asp:ListItem>
							<asp:ListItem value="BG">Bulgaria</asp:ListItem>
							<asp:ListItem value="BF">Burkina Faso</asp:ListItem>
							<asp:ListItem value="BI">Burundi</asp:ListItem>
							<asp:ListItem value="KH">Cambodia</asp:ListItem>
							<asp:ListItem value="CM">Cameroon</asp:ListItem>
							<asp:ListItem value="CA">Canada</asp:ListItem>
							<asp:ListItem value="CV">Cape Verde</asp:ListItem>
							<asp:ListItem value="KY">Cayman Islands</asp:ListItem>
							<asp:ListItem value="CF">Central African Republic</asp:ListItem>
							<asp:ListItem value="TD">Chad</asp:ListItem>
							<asp:ListItem value="CL">Chile</asp:ListItem>
							<asp:ListItem value="CN">China</asp:ListItem>
							<asp:ListItem value="CX">Christmas Island</asp:ListItem>
							<asp:ListItem value="CC">Cocos (Keeling) Islands</asp:ListItem>
							<asp:ListItem value="CO">Colombia</asp:ListItem>
							<asp:ListItem value="KM">Comoros</asp:ListItem>
							<asp:ListItem value="CG">Congo</asp:ListItem>
							<asp:ListItem value="CD">Congo, The Democratic Republic of The</asp:ListItem>
							<asp:ListItem value="CK">Cook Islands</asp:ListItem>
							<asp:ListItem value="CR">Costa Rica</asp:ListItem>
							<asp:ListItem value="CI">Cote D'ivoire</asp:ListItem>
							<asp:ListItem value="HR">Croatia</asp:ListItem>
							<asp:ListItem value="CU">Cuba</asp:ListItem>
							<asp:ListItem value="CY">Cyprus</asp:ListItem>
							<asp:ListItem value="CZ">Czech Republic</asp:ListItem>
							<asp:ListItem value="DK">Denmark</asp:ListItem>
							<asp:ListItem value="DJ">Djibouti</asp:ListItem>
							<asp:ListItem value="DM">Dominica</asp:ListItem>
							<asp:ListItem value="DO">Dominican Republic</asp:ListItem>
							<asp:ListItem value="EC">Ecuador</asp:ListItem>
							<asp:ListItem value="EG">Egypt</asp:ListItem>
							<asp:ListItem value="SV">El Salvador</asp:ListItem>
							<asp:ListItem value="GQ">Equatorial Guinea</asp:ListItem>
							<asp:ListItem value="ER">Eritrea</asp:ListItem>
							<asp:ListItem value="EE">Estonia</asp:ListItem>
							<asp:ListItem value="ET">Ethiopia</asp:ListItem>
							<asp:ListItem value="FK">Falkland Islands (Malvinas)</asp:ListItem>
							<asp:ListItem value="FO">Faroe Islands</asp:ListItem>
							<asp:ListItem value="FJ">Fiji</asp:ListItem>
							<asp:ListItem value="FI">Finland</asp:ListItem>
							<asp:ListItem value="FR">France</asp:ListItem>
							<asp:ListItem value="GF">French Guiana</asp:ListItem>
							<asp:ListItem value="PF">French Polynesia</asp:ListItem>
							<asp:ListItem value="TF">French Southern Territories</asp:ListItem>
							<asp:ListItem value="GA">Gabon</asp:ListItem>
							<asp:ListItem value="GM">Gambia</asp:ListItem>
							<asp:ListItem value="GE">Georgia</asp:ListItem>
							<asp:ListItem value="DE">Germany</asp:ListItem>
							<asp:ListItem value="GH">Ghana</asp:ListItem>
							<asp:ListItem value="GI">Gibraltar</asp:ListItem>
							<asp:ListItem value="GR">Greece</asp:ListItem>
							<asp:ListItem value="GL">Greenland</asp:ListItem>
							<asp:ListItem value="GD">Grenada</asp:ListItem>
							<asp:ListItem value="GP">Guadeloupe</asp:ListItem>
							<asp:ListItem value="GU">Guam</asp:ListItem>
							<asp:ListItem value="GT">Guatemala</asp:ListItem>
							<asp:ListItem value="GG">Guernsey</asp:ListItem>
							<asp:ListItem value="GN">Guinea</asp:ListItem>
							<asp:ListItem value="GW">Guinea-bissau</asp:ListItem>
							<asp:ListItem value="GY">Guyana</asp:ListItem>
							<asp:ListItem value="HT">Haiti</asp:ListItem>
							<asp:ListItem value="HM">Heard Island and Mcdonald Islands</asp:ListItem>
							<asp:ListItem value="VA">Holy See (Vatican City State)</asp:ListItem>
							<asp:ListItem value="HN">Honduras</asp:ListItem>
							<asp:ListItem value="HK">Hong Kong</asp:ListItem>
							<asp:ListItem value="HU">Hungary</asp:ListItem>
							<asp:ListItem value="IS">Iceland</asp:ListItem>
							<asp:ListItem value="IN">India</asp:ListItem>
							<asp:ListItem value="ID">Indonesia</asp:ListItem>
							<asp:ListItem value="IR">Iran, Islamic Republic of</asp:ListItem>
							<asp:ListItem value="IQ">Iraq</asp:ListItem>
							<asp:ListItem value="IE">Ireland</asp:ListItem>
							<asp:ListItem value="IM">Isle of Man</asp:ListItem>
							<asp:ListItem value="IL">Israel</asp:ListItem>
							<asp:ListItem value="IT">Italy</asp:ListItem>
							<asp:ListItem value="JM">Jamaica</asp:ListItem>
							<asp:ListItem value="JP">Japan</asp:ListItem>
							<asp:ListItem value="JE">Jersey</asp:ListItem>
							<asp:ListItem value="JO">Jordan</asp:ListItem>
							<asp:ListItem value="KZ">Kazakhstan</asp:ListItem>
							<asp:ListItem value="KE">Kenya</asp:ListItem>
							<asp:ListItem value="KI">Kiribati</asp:ListItem>
							<asp:ListItem value="KP">Korea, Democratic People's Republic of</asp:ListItem>
							<asp:ListItem value="KR">Korea, Republic of</asp:ListItem>
							<asp:ListItem value="KW">Kuwait</asp:ListItem>
							<asp:ListItem value="KG">Kyrgyzstan</asp:ListItem>
							<asp:ListItem value="LA">Lao People's Democratic Republic</asp:ListItem>
							<asp:ListItem value="LV">Latvia</asp:ListItem>
							<asp:ListItem value="LB">Lebanon</asp:ListItem>
							<asp:ListItem value="LS">Lesotho</asp:ListItem>
							<asp:ListItem value="LR">Liberia</asp:ListItem>
							<asp:ListItem value="LY">Libyan Arab Jamahiriya</asp:ListItem>
							<asp:ListItem value="LI">Liechtenstein</asp:ListItem>
							<asp:ListItem value="LT">Lithuania</asp:ListItem>
							<asp:ListItem value="LU">Luxembourg</asp:ListItem>
							<asp:ListItem value="MO">Macao</asp:ListItem>
							<asp:ListItem value="MK">Macedonia, The Former Yugoslav Republic of</asp:ListItem>
							<asp:ListItem value="MG">Madagascar</asp:ListItem>
							<asp:ListItem value="MW">Malawi</asp:ListItem>
							<asp:ListItem value="MY">Malaysia</asp:ListItem>
							<asp:ListItem value="MV">Maldives</asp:ListItem>
							<asp:ListItem value="ML">Mali</asp:ListItem>
							<asp:ListItem value="MT">Malta</asp:ListItem>
							<asp:ListItem value="MH">Marshall Islands</asp:ListItem>
							<asp:ListItem value="MQ">Martinique</asp:ListItem>
							<asp:ListItem value="MR">Mauritania</asp:ListItem>
							<asp:ListItem value="MU">Mauritius</asp:ListItem>
							<asp:ListItem value="YT">Mayotte</asp:ListItem>
							<asp:ListItem value="MX">Mexico</asp:ListItem>
							<asp:ListItem value="FM">Micronesia, Federated States of</asp:ListItem>
							<asp:ListItem value="MD">Moldova, Republic of</asp:ListItem>
							<asp:ListItem value="MC">Monaco</asp:ListItem>
							<asp:ListItem value="MN">Mongolia</asp:ListItem>
							<asp:ListItem value="ME">Montenegro</asp:ListItem>
							<asp:ListItem value="MS">Montserrat</asp:ListItem>
							<asp:ListItem value="MA">Morocco</asp:ListItem>
							<asp:ListItem value="MZ">Mozambique</asp:ListItem>
							<asp:ListItem value="MM">Myanmar</asp:ListItem>
							<asp:ListItem value="NA">Namibia</asp:ListItem>
							<asp:ListItem value="NR">Nauru</asp:ListItem>
							<asp:ListItem value="NP">Nepal</asp:ListItem>
							<asp:ListItem value="NL">Netherlands</asp:ListItem>
							<asp:ListItem value="AN">Netherlands Antilles</asp:ListItem>
							<asp:ListItem value="NC">New Caledonia</asp:ListItem>
							<asp:ListItem value="NZ">New Zealand</asp:ListItem>
							<asp:ListItem value="NI">Nicaragua</asp:ListItem>
							<asp:ListItem value="NE">Niger</asp:ListItem>
							<asp:ListItem value="NG">Nigeria</asp:ListItem>
							<asp:ListItem value="NU">Niue</asp:ListItem>
							<asp:ListItem value="NF">Norfolk Island</asp:ListItem>
							<asp:ListItem value="MP">Northern Mariana Islands</asp:ListItem>
							<asp:ListItem value="NO">Norway</asp:ListItem>
							<asp:ListItem value="OM">Oman</asp:ListItem>
							<asp:ListItem value="PK">Pakistan</asp:ListItem>
							<asp:ListItem value="PW">Palau</asp:ListItem>
							<asp:ListItem value="PS">Palestinian Territory, Occupied</asp:ListItem>
							<asp:ListItem value="PA">Panama</asp:ListItem>
							<asp:ListItem value="PG">Papua New Guinea</asp:ListItem>
							<asp:ListItem value="PY">Paraguay</asp:ListItem>
							<asp:ListItem value="PE">Peru</asp:ListItem>
							<asp:ListItem value="PH">Philippines</asp:ListItem>
							<asp:ListItem value="PN">Pitcairn</asp:ListItem>
							<asp:ListItem value="PL">Poland</asp:ListItem>
							<asp:ListItem value="PT">Portugal</asp:ListItem>
							<asp:ListItem value="PR">Puerto Rico</asp:ListItem>
							<asp:ListItem value="QA">Qatar</asp:ListItem>
							<asp:ListItem value="RE">Reunion</asp:ListItem>
							<asp:ListItem value="RO">Romania</asp:ListItem>
							<asp:ListItem value="RU">Russian Federation</asp:ListItem>
							<asp:ListItem value="RW">Rwanda</asp:ListItem>
							<asp:ListItem value="SH">Saint Helena</asp:ListItem>
							<asp:ListItem value="KN">Saint Kitts and Nevis</asp:ListItem>
							<asp:ListItem value="LC">Saint Lucia</asp:ListItem>
							<asp:ListItem value="PM">Saint Pierre and Miquelon</asp:ListItem>
							<asp:ListItem value="VC">Saint Vincent and The Grenadines</asp:ListItem>
							<asp:ListItem value="WS">Samoa</asp:ListItem>
							<asp:ListItem value="SM">San Marino</asp:ListItem>
							<asp:ListItem value="ST">Sao Tome and Principe</asp:ListItem>
							<asp:ListItem value="SA">Saudi Arabia</asp:ListItem>
							<asp:ListItem value="SN">Senegal</asp:ListItem>
							<asp:ListItem value="RS">Serbia</asp:ListItem>
							<asp:ListItem value="SC">Seychelles</asp:ListItem>
							<asp:ListItem value="SL">Sierra Leone</asp:ListItem>
							<asp:ListItem value="SG">Singapore</asp:ListItem>
							<asp:ListItem value="SK">Slovakia</asp:ListItem>
							<asp:ListItem value="SI">Slovenia</asp:ListItem>
							<asp:ListItem value="SB">Solomon Islands</asp:ListItem>
							<asp:ListItem value="SO">Somalia</asp:ListItem>
							<asp:ListItem value="ZA">South Africa</asp:ListItem>
							<asp:ListItem value="GS">South Georgia and The South Sandwich Islands</asp:ListItem>
							<asp:ListItem value="ES">Spain</asp:ListItem>
							<asp:ListItem value="LK">Sri Lanka</asp:ListItem>
							<asp:ListItem value="SD">Sudan</asp:ListItem>
							<asp:ListItem value="SR">Suriname</asp:ListItem>
							<asp:ListItem value="SJ">Svalbard and Jan Mayen</asp:ListItem>
							<asp:ListItem value="SZ">Swaziland</asp:ListItem>
							<asp:ListItem value="SE">Sweden</asp:ListItem>
							<asp:ListItem value="CH">Switzerland</asp:ListItem>
							<asp:ListItem value="SY">Syrian Arab Republic</asp:ListItem>
							<asp:ListItem value="TW">Taiwan, Province of China</asp:ListItem>
							<asp:ListItem value="TJ">Tajikistan</asp:ListItem>
							<asp:ListItem value="TZ">Tanzania, United Republic of</asp:ListItem>
							<asp:ListItem value="TH">Thailand</asp:ListItem>
							<asp:ListItem value="TL">Timor-leste</asp:ListItem>
							<asp:ListItem value="TG">Togo</asp:ListItem>
							<asp:ListItem value="TK">Tokelau</asp:ListItem>
							<asp:ListItem value="TO">Tonga</asp:ListItem>
							<asp:ListItem value="TT">Trinidad and Tobago</asp:ListItem>
							<asp:ListItem value="TN">Tunisia</asp:ListItem>
							<asp:ListItem value="TR">Turkey</asp:ListItem>
							<asp:ListItem value="TM">Turkmenistan</asp:ListItem>
							<asp:ListItem value="TC">Turks and Caicos Islands</asp:ListItem>
							<asp:ListItem value="TV">Tuvalu</asp:ListItem>
							<asp:ListItem value="UG">Uganda</asp:ListItem>
							<asp:ListItem value="UA">Ukraine</asp:ListItem>
							<asp:ListItem value="AE">United Arab Emirates</asp:ListItem>
							<asp:ListItem value="GB">United Kingdom</asp:ListItem>
							<asp:ListItem value="US" Selected="True">United States</asp:ListItem>
							<asp:ListItem value="UM">United States Minor Outlying Islands</asp:ListItem>
							<asp:ListItem value="UY">Uruguay</asp:ListItem>
							<asp:ListItem value="UZ">Uzbekistan</asp:ListItem>
							<asp:ListItem value="VU">Vanuatu</asp:ListItem>
							<asp:ListItem value="VE">Venezuela</asp:ListItem>
							<asp:ListItem value="VN">Viet Nam</asp:ListItem>
							<asp:ListItem value="VG">Virgin Islands, British</asp:ListItem>
							<asp:ListItem value="VI">Virgin Islands, U.S.</asp:ListItem>
							<asp:ListItem value="WF">Wallis and Futuna</asp:ListItem>
							<asp:ListItem value="EH">Western Sahara</asp:ListItem>
							<asp:ListItem value="YE">Yemen</asp:ListItem>
							<asp:ListItem value="ZM">Zambia</asp:ListItem>
							<asp:ListItem value="ZW">Zimbabwe</asp:ListItem>
							</asp:DropDownList></td>
                            <td>
                           </td>
						</tr>
                        <tr><td>Phone:</td><td>
                            <asp:TextBox runat="server" id="PHONE" Text="10022" />
                                           </td></tr>
						
                        <tr><td colspan="2"><p class="lead"><u>Shipping Method</u></p></td></tr>
                        <tr><td>Shipping Type:</td>
                            <td>
                    <select name="shipping_method" ID="shipping_method" style="width: 250px;" class="required-entry">
                        <option value="0.00">Select shipping method</option>
					<optgroup label="United Parcel Service" style="font-style:normal;">
					<option value="2.00">
					Worldwide Expedited - $2.00</option>
					<option value="3.00">
					Worldwide Express Saver - $3.00</option>
					</optgroup>
					<optgroup label="Flat Rate" style="font-style:normal;">
					<option value="5.00" selected>
					Fixed - $0.00</option>
					</optgroup>
					</select>
                               
						</td></tr>
					<tr><td colspan="2"><p class="lead">Payment Methods:</p></td></tr>	
					<tr><td colspan="2">
						<input id="paypal_payment_option" value="paypal_express" type="radio" name="payment[method]" title="PayPal Express Checkout" class="radio" checked>
						<img src="https://fpdbs.paypal.com/dynamicimageweb?cmd=_dynamic-image&amp;buttontype=ecmark&amp;locale=en_US" alt="Acceptance Mark" class="v-middle">&nbsp;
						<a href="https://www.paypal.com/us/cgi-bin/webscr?cmd=xpt/Marketing/popup/OLCWhatIsPayPal-outside" onclick="javascript:window.open('https://www.paypal.com/us/cgi-bin/webscr?cmd=xpt/Marketing/popup/OLCWhatIsPayPal-outside','olcwhatispaypal','toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, ,left=0, top=0, width=400, height=350'); return false;">What is PayPal?</a>
					</td></tr>
					<tr><td colspan="2"><input id="payment_method_creditcard" value="paypal_express" type="radio" name="payment[method]" title="PayPal Express Checkout" class="radio" readonly disabled>&nbsp;Credit Card</td></tr>
					<tr><td>&nbsp;</td></tr>
						<tr><td colspan="2">
                            <input type="submit" id="placeOrderBtn" class="btn btn-primary btn-large" name="PlaceOrder" value="Place Order" />
                             </td></tr>
                        </table>
                  </div>
               </div>
            </form>
   </div>
   <div class="span3">
   </div>
			</div> <!-- Row-Fluid ends here -->
		</div>  <!--Container-Fluid ends here -->
		<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
		<script src="https://code.jquery.com/jquery.js"></script>
		<!-- Include all compiled plugins (below), or include individual files as needed -->
		<script src="js/bootstrap.min.js"></script>
    
   <script type="text/javascript">
       window.paypalCheckoutReady = function () {
           paypal.checkout.setup('supersandy@gmail.com', {
               button: 'placeOrderBtn',
               environment: 'sandbox',
               condition: function () {
                   return document.getElementById('paypal_payment_option').checked === true;
               }
           });
       };
   </script>
          <script src="//www.paypalobjects.com/api/checkout.js" async></script>
	</body>
</html>