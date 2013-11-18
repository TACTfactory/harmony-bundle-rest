package com.tactfactory.harmony.test.demact.entity;


import java.io.Serializable;
import com.tactfactory.harmony.annotation.Column;
import com.tactfactory.harmony.annotation.Entity;
import com.tactfactory.harmony.bundles.rest.annotation.Rest;

@Entity
@Rest
public class Client extends User implements Serializable {

	@Column
	private String adress;
	/**
	 * @return the adress
	 */
	public String getAdress() {
	     return this.adress;
	}


	/**
	 * @param value the adress to set
	 */
	public void setAdress(final String value) {
	     this.adress = value;
	}

}
