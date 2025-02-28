<?php
/**
 * Copyright (c) 2014 Lukas Reschke <lukas@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test;

class HTTPHelperTest extends \Test\TestCase {
	/** @var \OCP\IConfig*/
	private $config;
	/** @var \OC\HTTPHelper */
	private $httpHelperMock;
	/** @var \OCP\Http\Client\IClientService */
	private $clientService;

	protected function setUp(): void {
		parent::setUp();

		$this->config = $this->getMockBuilder('\OCP\IConfig')
			->disableOriginalConstructor()->getMock();
		$this->clientService = $this->createMock('\OCP\Http\Client\IClientService');
		$this->httpHelperMock = $this->getMockBuilder('\OC\HTTPHelper')
			->setConstructorArgs([$this->config, $this->clientService])
			->setMethods(['getHeaders'])
			->getMock();
	}

	public function isHttpTestData() {
		return [
			['http://wwww.owncloud.com/enterprise/', true],
			['https://wwww.owncloud.com/enterprise/', true],
			['HTTPS://WWW.OWNCLOUD.COM', true],
			['HTTP://WWW.OWNCLOUD.COM', true],
			['FILE://WWW.OWNCLOUD.COM', false],
			['file://www.owncloud.com', false],
			['FTP://WWW.OWNCLOUD.COM', false],
			['ftp://www.owncloud.com', false],
		];
	}

	/**
	 * @dataProvider isHttpTestData
	 */
	public function testIsHTTP($url, $expected) {
		$this->assertSame($expected, $this->httpHelperMock->isHTTPURL($url));
	}

	public function testPostSuccess() {
		$client = $this->getMockBuilder('\OCP\Http\Client\IClient')
			->disableOriginalConstructor()->getMock();
		$this->clientService
			->expects($this->once())
			->method('newClient')
			->will($this->returnValue($client));
		$response = $this->getMockBuilder('\OCP\Http\Client\IResponse')
			->disableOriginalConstructor()->getMock();
		$client
			->expects($this->once())
			->method('post')
			->with(
				'https://owncloud.com',
				[
					'body' => [
						'Foo' => 'Bar',
					],
					'connect_timeout' => 10,

				]
			)
			->will($this->returnValue($response));
		$response
			->expects($this->once())
			->method('getBody')
			->will($this->returnValue('Body of the requested page'));

		$response = $this->httpHelperMock->post('https://owncloud.com', ['Foo' => 'Bar']);
		$expected = [
			'success' => true,
			'result' => 'Body of the requested page'
		];
		$this->assertSame($expected, $response);
	}

	public function testPostException() {
		$client = $this->getMockBuilder('\OCP\Http\Client\IClient')
			->disableOriginalConstructor()->getMock();
		$this->clientService
			->expects($this->once())
			->method('newClient')
			->will($this->returnValue($client));
		$client
			->expects($this->once())
			->method('post')
			->with(
				'https://owncloud.com',
				[
					'body' => [
						'Foo' => 'Bar',
					],
					'connect_timeout' => 10,

				]
			)
			->will($this->throwException(new \Exception('Something failed')));

		$response = $this->httpHelperMock->post('https://owncloud.com', ['Foo' => 'Bar']);
		$expected = [
			'success' => false,
			'result' => 'Something failed'
		];
		$this->assertSame($expected, $response);
	}
}
